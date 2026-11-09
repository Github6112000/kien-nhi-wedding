# One-off asset preparation for the 3 detail images (run once, then delete).
#  - hands-envelope.png / flowers.png : upscale 3x, remove the white screenshot background, light sharpen
#  - bg-wine.png -> bg-wine.jpg      : trim white edges, paint out the faint divider line, build a seamless mirrored tile
$code = @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class ImgTool {
  static byte[] Read(Bitmap b, out int stride) {
    var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
    stride = d.Stride;
    var buf = new byte[stride * b.Height];
    Marshal.Copy(d.Scan0, buf, 0, buf.Length);
    b.UnlockBits(d);
    return buf;
  }
  static void Write(Bitmap b, byte[] buf) {
    var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
    Marshal.Copy(buf, 0, d.Scan0, buf.Length);
    b.UnlockBits(d);
  }
  static int White(byte[] px, int stride, int w, int i) {
    int o = (i / w) * stride + (i % w) * 4;
    return Math.Min(px[o], Math.Min(px[o + 1], px[o + 2]));
  }

  public static Bitmap Upscale(string path, int f) {
    using (var src = new Bitmap(path)) {
      var dst = new Bitmap(src.Width * f, src.Height * f, PixelFormat.Format32bppArgb);
      using (var g = Graphics.FromImage(dst))
      using (var ia = new ImageAttributes()) {
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
        g.CompositingQuality = CompositingQuality.HighQuality;
        ia.SetWrapMode(WrapMode.TileFlipXY);
        g.DrawImage(src, new Rectangle(0, 0, dst.Width, dst.Height), 0, 0, src.Width, src.Height, GraphicsUnit.Pixel, ia);
      }
      return dst;
    }
  }

  // Removes near-white pixels connected to the image border; feathers + de-whitens a thin ring at the edge.
  public static int KnockOutWhite(Bitmap b, int hard, int soft, int ring) {
    int w = b.Width, h = b.Height, stride;
    byte[] px = Read(b, out stride);
    int n = w * h;
    int[] dist = new int[n];
    for (int i = 0; i < n; i++) dist[i] = int.MaxValue;
    var q = new Queue<int>();
    for (int x = 0; x < w; x++) {
      int a = x, c = (h - 1) * w + x;
      if (White(px, stride, w, a) >= hard && dist[a] != 0) { dist[a] = 0; q.Enqueue(a); }
      if (White(px, stride, w, c) >= hard && dist[c] != 0) { dist[c] = 0; q.Enqueue(c); }
    }
    for (int y = 0; y < h; y++) {
      int a = y * w, c = y * w + w - 1;
      if (White(px, stride, w, a) >= hard && dist[a] != 0) { dist[a] = 0; q.Enqueue(a); }
      if (White(px, stride, w, c) >= hard && dist[c] != 0) { dist[c] = 0; q.Enqueue(c); }
    }
    int removed = 0;
    while (q.Count > 0) {
      int i = q.Dequeue(); removed++;
      int x = i % w, y = i / w;
      int[] nb = { x > 0 ? i - 1 : -1, x < w - 1 ? i + 1 : -1, y > 0 ? i - w : -1, y < h - 1 ? i + w : -1 };
      foreach (int j in nb) {
        if (j < 0 || dist[j] == 0) continue;
        if (White(px, stride, w, j) >= hard) { dist[j] = 0; q.Enqueue(j); }
      }
    }
    var r = new Queue<int>();
    for (int i = 0; i < n; i++) if (dist[i] == 0) r.Enqueue(i);
    while (r.Count > 0) {
      int i = r.Dequeue(); int d = dist[i];
      if (d >= ring) continue;
      int x = i % w, y = i / w;
      int[] nb = { x > 0 ? i - 1 : -1, x < w - 1 ? i + 1 : -1, y > 0 ? i - w : -1, y < h - 1 ? i + w : -1 };
      foreach (int j in nb) {
        if (j < 0) continue;
        if (dist[j] > d + 1) { dist[j] = d + 1; r.Enqueue(j); }
      }
    }
    for (int i = 0; i < n; i++) {
      int o = (i / w) * stride + (i % w) * 4;
      if (dist[i] == 0) { px[o] = 0; px[o + 1] = 0; px[o + 2] = 0; px[o + 3] = 0; continue; }
      if (dist[i] <= ring) {
        int wv = Math.Min(px[o], Math.Min(px[o + 1], px[o + 2]));
        if (wv > soft) {
          double a = (255.0 - wv) / (255.0 - soft);
          if (a < 0) a = 0; if (a > 1) a = 1;
          for (int c = 0; c < 3; c++) {
            double v = a > 0.02 ? (px[o + c] - 255.0 * (1 - a)) / a : 0;
            px[o + c] = (byte)Math.Max(0, Math.Min(255, Math.Round(v)));
          }
          px[o + 3] = (byte)Math.Round(a * 255);
        }
      }
    }
    Write(b, px);
    return removed;
  }

  // Unsharp mask that ignores transparent neighbours (no halos at cut-out edges).
  public static void Unsharp(Bitmap b, double amount) {
    int w = b.Width, h = b.Height, stride;
    byte[] px = Read(b, out stride);
    byte[] src = (byte[])px.Clone();
    int[] k = { 1, 2, 1, 2, 4, 2, 1, 2, 1 };
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        int o = y * stride + x * 4;
        if (src[o + 3] == 0) continue;
        for (int c = 0; c < 3; c++) {
          double sum = 0, wsum = 0; int ki = 0;
          for (int dy = -1; dy <= 1; dy++) for (int dx = -1; dx <= 1; dx++, ki++) {
            int oo = (y + dy) * stride + (x + dx) * 4;
            if (src[oo + 3] < 128) continue;
            sum += src[oo + c] * k[ki]; wsum += k[ki];
          }
          if (wsum == 0) continue;
          double v = src[o + c] + amount * (src[o + c] - sum / wsum);
          px[o + c] = (byte)Math.Max(0, Math.Min(255, Math.Round(v)));
        }
      }
    }
    Write(b, px);
  }

  public static string MakeBgTile(string path, string outPath, long quality) {
    Bitmap src;
    using (var s0 = new Bitmap(path)) src = new Bitmap(s0);
    int w = src.Width, h = src.Height, stride;
    byte[] px = Read(src, out stride);
    double[] ravg = new double[h]; int[] rmax = new int[h];
    double[] cavg = new double[w];
    for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
      int o = y * stride + x * 4; int l = (px[o] + px[o + 1] + px[o + 2]) / 3;
      ravg[y] += l / (double)w; cavg[x] += l / (double)h; if (l > rmax[y]) rmax[y] = l;
    }
    int top = 0; while (top < h - 1 && ravg[top] > 34) top++;
    int bot = h - 1; while (bot > top && ravg[bot] > 34) bot--;
    int left = 0; while (left < w - 1 && cavg[left] > 34) left++;
    int right = w - 1; while (right > left && cavg[right] > 34) right--;
    top += 1; bot -= 1; left += 1; right -= 1;   // drop anti-aliased edge rows too

    // rows containing the faint divider line / glow
    var maxes = new List<int>();
    for (int y = top; y <= bot; y++) maxes.Add(rmax[y]);
    maxes.Sort();
    int med = maxes[maxes.Count / 2];
    bool[] bad = new bool[h];
    for (int y = top; y <= bot; y++) if (rmax[y] > med + 12) for (int d = -3; d <= 3; d++) { int yy = y + d; if (yy >= top && yy <= bot) bad[yy] = true; }
    int fixedRows = 0;
    int firstBad = -1, lastBad = -1;
    for (int y = top; y <= bot; y++) if (bad[y]) { if (firstBad < 0) firstBad = y; lastBad = y; }
    if (firstBad >= 0) {
      int span = lastBad - firstBad + 1;
      for (int y = firstBad; y <= lastBad; y++) {
        int sy = y - span - 2; if (sy < top) sy = y + span + 2;
        Buffer.BlockCopy(px, sy * stride, px, y * stride, stride);
        fixedRows++;
      }
    }
    Write(src, px);

    int cw = right - left + 1, ch = bot - top + 1;
    var crop = new Rectangle(left, top, cw, ch);

    // Flatten: keep only the fine weave (high-pass) around the mean colour, so the
    // mirrored tile has no vignette rings / visible repeats.
    {
      int R = 14;
      double[] mean = new double[3];
      for (int y = top; y <= bot; y++) for (int x = left; x <= right; x++) {
        int o = y * stride + x * 4; for (int c = 0; c < 3; c++) mean[c] += px[o + c];
      }
      for (int c = 0; c < 3; c++) mean[c] /= (double)(cw * ch);
      byte[] orig = (byte[])px.Clone();
      for (int y = top; y <= bot; y++) for (int x = left; x <= right; x++) {
        int y0 = Math.Max(top, y - R), y1 = Math.Min(bot, y + R), x0 = Math.Max(left, x - R), x1 = Math.Min(right, x + R);
        double[] s = new double[3]; int cnt = 0;
        for (int yy = y0; yy <= y1; yy += 2) for (int xx = x0; xx <= x1; xx += 2) {
          int oo = yy * stride + xx * 4; s[0] += orig[oo]; s[1] += orig[oo + 1]; s[2] += orig[oo + 2]; cnt++;
        }
        int o = y * stride + x * 4;
        for (int c = 0; c < 3; c++) {
          double v = orig[o + c] - s[c] / cnt + mean[c];
          px[o + c] = (byte)Math.Max(0, Math.Min(255, Math.Round(v)));
        }
      }
      Write(src, px);
    }
    using (var tile = new Bitmap(cw * 2, ch * 2, PixelFormat.Format24bppRgb))
    using (var a = src.Clone(crop, PixelFormat.Format24bppRgb)) {
      using (var g = Graphics.FromImage(tile)) {
        g.DrawImage(a, 0, 0, cw, ch);
        a.RotateFlip(RotateFlipType.RotateNoneFlipX); g.DrawImage(a, cw, 0, cw, ch);
        a.RotateFlip(RotateFlipType.RotateNoneFlipY); g.DrawImage(a, cw, ch, cw, ch);
        a.RotateFlip(RotateFlipType.RotateNoneFlipX); g.DrawImage(a, 0, ch, cw, ch);
      }
      ImageCodecInfo jpg = null;
      foreach (var c in ImageCodecInfo.GetImageEncoders()) if (c.MimeType == "image/jpeg") jpg = c;
      var ep = new EncoderParameters(1);
      ep.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
      tile.Save(outPath, jpg, ep);
    }
    src.Dispose();
    return string.Format("crop=({0},{1},{2}x{3}) median={4} fixedRows={5} [{6}-{7}] tile={8}x{9}",
      left, top, cw, ch, med, fixedRows, firstBad, lastBad, cw * 2, ch * 2);
  }
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$img = "d:\VTVLive\thiepcuoi\web\assets\images"
$log = "d:\VTVLive\thiepcuoi\process.txt"
Set-Content $log "start" -Encoding UTF8

foreach ($name in "hands-envelope.png", "flowers.png") {
  $path = Join-Path $img $name
  $big = [ImgTool]::Upscale($path, 3)
  $removed = [ImgTool]::KnockOutWhite($big, 244, 205, 3)
  [ImgTool]::Unsharp($big, 0.55)
  $tmp = "$path.tmp.png"
  $big.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
  Add-Content $log "$name -> $($big.Width)x$($big.Height), removed $removed bg px"
  $big.Dispose()
  Move-Item -Force $tmp $path
}

$info = [ImgTool]::MakeBgTile((Join-Path $img "bg-wine.png"), (Join-Path $img "bg-wine.jpg"), 92)
Add-Content $log "bg: $info"
Remove-Item (Join-Path $img "bg-wine.png")
Add-Content $log "done"
