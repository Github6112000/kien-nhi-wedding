# v2 cut-outs from the ORIGINAL detail images: better halo removal, shadow removal (flowers),
# and soft fades where the subject is cropped by the image frame.
$code = @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class Cut {
  static byte[] Read(Bitmap b, out int stride) {
    var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
    stride = d.Stride; var buf = new byte[stride * b.Height];
    Marshal.Copy(d.Scan0, buf, 0, buf.Length); b.UnlockBits(d); return buf;
  }
  static void Write(Bitmap b, byte[] buf) {
    var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
    Marshal.Copy(buf, 0, d.Scan0, buf.Length); b.UnlockBits(d);
  }

  public static string Sample(string path, int x0, int y0, int x1, int y1) {
    using (var b = new Bitmap(path)) {
      var s = new System.Text.StringBuilder();
      for (int y = y0; y <= y1; y += 4) { for (int x = x0; x <= x1; x += 6) { var p = b.GetPixel(x, y); s.AppendFormat("{0:X2}{1:X2}{2:X2} ", p.R, p.G, p.B); } s.Append("\n"); }
      return s.ToString();
    }
  }

  public static Bitmap Upscale(string path, int f) {
    using (var src = new Bitmap(path)) {
      var dst = new Bitmap(src.Width * f, src.Height * f, PixelFormat.Format32bppArgb);
      using (var g = Graphics.FromImage(dst))
      using (var ia = new ImageAttributes()) {
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
        ia.SetWrapMode(WrapMode.TileFlipXY);
        g.DrawImage(src, new Rectangle(0, 0, dst.Width, dst.Height), 0, 0, src.Width, src.Height, GraphicsUnit.Pixel, ia);
      }
      return dst;
    }
  }

  static bool IsBg(byte[] px, int o, int hard, bool greyShadow) {
    int b = px[o], g = px[o + 1], r = px[o + 2];
    int mn = Math.Min(r, Math.Min(g, b)), mx = Math.Max(r, Math.Max(g, b));
    if (mn >= hard) return true;
    if (greyShadow && mn >= 120 && (mx - mn) <= 10 && (b - r) >= -3) return true;   // neutral/cool drop shadow on white
    return false;
  }

  // fadeL/R/T/B = fraction of width/height over which alpha fades to 0 at that frame edge (0 = none)
  public static int Run(Bitmap bmp, int hard, bool greyShadow, int ring,
                            double fadeL, double fadeR, double fadeT, double fadeB, double sharpen) {
    int w = bmp.Width, h = bmp.Height, stride;
    byte[] px = Read(bmp, out stride);
    int n = w * h;
    int[] dist = new int[n];
    for (int i = 0; i < n; i++) dist[i] = int.MaxValue;
    var q = new Queue<int>();
    for (int i = 0; i < n; i++) {
      int x = i % w, y = i / w;
      if (x == 0 || y == 0 || x == w - 1 || y == h - 1) {
        if (IsBg(px, y * stride + x * 4, hard, greyShadow)) { dist[i] = 0; q.Enqueue(i); }
      }
    }
    int removed = 0;
    while (q.Count > 0) {
      int i = q.Dequeue(); removed++;
      int x = i % w, y = i / w;
      for (int k = 0; k < 4; k++) {
        int nx = x + (k == 0 ? -1 : k == 1 ? 1 : 0), ny = y + (k == 2 ? -1 : k == 3 ? 1 : 0);
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        int j = ny * w + nx;
        if (dist[j] == 0) continue;
        if (IsBg(px, ny * stride + nx * 4, hard, greyShadow)) { dist[j] = 0; q.Enqueue(j); }
      }
    }
    // distance (in px) from the background into the subject, up to ring
    var r = new Queue<int>();
    for (int i = 0; i < n; i++) if (dist[i] == 0) r.Enqueue(i);
    while (r.Count > 0) {
      int i = r.Dequeue(); int d = dist[i]; if (d >= ring) continue;
      int x = i % w, y = i / w;
      for (int k = 0; k < 8; k++) {
        int dx = new int[] { -1, 1, 0, 0, -1, 1, -1, 1 }[k], dy = new int[] { 0, 0, -1, 1, -1, -1, 1, 1 }[k];
        int nx = x + dx, ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        int j = ny * w + nx;
        if (dist[j] > d + 1) { dist[j] = d + 1; r.Enqueue(j); }
      }
    }
    for (int i = 0; i < n; i++) {
      int x = i % w, y = i / w, o = y * stride + x * 4;
      double a;
      if (dist[i] == 0) a = 0;
      else if (dist[i] <= ring) {
        // erode + feather the edge ring and remove the white it was blended with
        double byDist = (double)dist[i] / (ring + 1);
        int mn = Math.Min(px[o], Math.Min(px[o + 1], px[o + 2]));
        double byWhite = Math.Max(0, Math.Min(1, (255.0 - mn) / 70.0));
        a = Math.Min(1, Math.Max(byDist, 0) * 0.5 + Math.Min(byDist * 1.4, byWhite) * 0.5);
        if (a > 0.02) {
          for (int c = 0; c < 3; c++) {
            double v = (px[o + c] - 255.0 * (1 - a)) / a;
            // don't over-darken: blend un-whitened value with original
            v = 0.7 * v + 0.3 * px[o + c];
            px[o + c] = (byte)Math.Max(0, Math.Min(255, Math.Round(v)));
          }
        }
      } else a = 1;

      // soft fade where the subject is cut by the frame
      if (fadeL > 0) a *= Smooth(x / (fadeL * w));
      if (fadeR > 0) a *= Smooth((w - 1 - x) / (fadeR * w));
      if (fadeT > 0) a *= Smooth(y / (fadeT * h));
      if (fadeB > 0) a *= Smooth((h - 1 - y) / (fadeB * h));
      px[o + 3] = (byte)Math.Round(Math.Max(0, Math.Min(1, a)) * 255);
      if (px[o + 3] == 0) { px[o] = 0; px[o + 1] = 0; px[o + 2] = 0; }
    }

    if (sharpen > 0) {
      byte[] src = (byte[])px.Clone();
      int[] kk = { 1, 2, 1, 2, 4, 2, 1, 2, 1 };
      for (int y = 1; y < h - 1; y++) for (int x = 1; x < w - 1; x++) {
        int o = y * stride + x * 4; if (src[o + 3] < 200) continue;
        for (int c = 0; c < 3; c++) {
          double s = 0, ws = 0; int ki = 0;
          for (int dy = -1; dy <= 1; dy++) for (int dx = -1; dx <= 1; dx++, ki++) {
            int oo = (y + dy) * stride + (x + dx) * 4; if (src[oo + 3] < 200) continue;
            s += src[oo + c] * kk[ki]; ws += kk[ki];
          }
          if (ws == 0) continue;
          double v = src[o + c] + sharpen * (src[o + c] - s / ws);
          px[o + c] = (byte)Math.Max(0, Math.Min(255, Math.Round(v)));
        }
      }
    }
    Write(bmp, px);
    return removed;
  }
  static double Smooth(double t) { if (t <= 0) return 0; if (t >= 1) return 1; return t * t * (3 - 2 * t); }
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$srcDir = (Get-ChildItem "d:\VTVLive\thiepcuoi" -Directory | Where-Object { $_.Name -like "chi ti*" } | Select-Object -First 1).FullName
$hands  = (Get-ChildItem -LiteralPath $srcDir -Filter "*(1).png" | Select-Object -First 1).FullName
$flower = (Get-ChildItem -LiteralPath $srcDir -Filter "*(2).png" | Select-Object -First 1).FullName
$img = "d:\VTVLive\thiepcuoi\web\assets\images"
$log = "d:\VTVLive\thiepcuoi\process.txt"
Add-Content $log "---- v2"
Add-Content $log ("flower bottom-left sample:`n" + [Cut]::Sample($flower, 2, 90, 50, 124))

# hands: white bg only (gloves are light grey, must not be treated as shadow); fade the cropped wrists
$b = [Cut]::Upscale($hands, 3)
$n = [Cut]::Run($b, [int]240, [bool]$false, [int]3, [double]0.10, [double]0.08, [double]0, [double]0, [double]0.45)
$b.Save("$img\hands-envelope.png", [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
Add-Content $log "hands removed=$n"

# flowers: white bg + neutral grey drop shadow; fade the flat crop at the bottom
$b = [Cut]::Upscale($flower, 3)
$n = [Cut]::Run($b, [int]238, [bool]$true, [int]3, [double]0, [double]0, [double]0, [double]0.16, [double]0.45)
$b.Save("$img\flowers.png", [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
Add-Content $log "flowers removed=$n"
Add-Content $log "v2 done"
