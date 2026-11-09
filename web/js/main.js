/**
 * Wedding invitation behaviour
 * - fills every section from wedding-data.js
 * - envelope intro: tap the envelope -> the invitation opens
 * - scroll reveals, gallery "show more", client-side RSVP
 */
(function () {
  "use strict";

  const $ = (id) => document.getElementById(id);
  const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------------- helpers ---------------- */
  function setText(id, value) {
    const el = $(id);
    if (el && value != null) el.textContent = value;
  }

  function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text != null) node.textContent = text;
    return node;
  }

  /* Guest name from ?khach=... (or ?to=...). textContent only, so no HTML injection. */
  function guestName() {
    const params = new URLSearchParams(window.location.search);
    const raw = (params.get("khach") || params.get("to") || "").trim();
    return raw ? raw.slice(0, 60) : wedding.defaultGuest;
  }

  /* ---------------- content ---------------- */
  function renderContent() {
    const { couple, date, reception } = wedding;

    document.title = `${couple.groomShort} & ${couple.brideShort} | Thiệp Cưới ${date.display}`;

    // envelope intro
    setText("env-date", date.display);
    setText("env-guest", guestName());
    setText("env-names", `${couple.groomShort} & ${couple.brideShort}`);

    // hero + closing
    ["hero", "closing"].forEach((prefix) => {
      setText(`${prefix}-groom`, couple.groomShort);
      setText(`${prefix}-bride`, couple.brideShort);
    });
    setText("hero-date", `${date.dayOfWeek} · ${date.display}`);
    setText("closing-date", date.display);
    setText("closing-text", wedding.closing);

    // greeting + calendar
    setText("greeting-title", wedding.greeting.title);
    setText("greeting-text", wedding.greeting.text);
    renderCalendar();

    setText("story-text", wedding.story && wedding.story.text);

    // couple profiles
    const { people } = wedding;
    setText("people-title", people.title);
    [["groom", couple.groomShort], ["bride", couple.brideShort]].forEach(([who, fullName]) => {
      setText(`${who}-role`, people[who].role);
      setText(`${who}-name`, fullName);
      const photo = $(`${who}-photo`);
      if (photo) photo.src = people[who].photo;
    });

    // venue
    setText("venue-address", reception.address);
    setText("venue-name", reception.venue);
    setText("venue-time", `lúc ${reception.welcomeTime}`);
    setText("venue-sub", reception.note);
    const maps = $("maps-link");
    if (maps) {
      maps.href = "https://www.google.com/maps/search/?api=1&query=" + encodeURIComponent(reception.mapsQuery);
    }

    // programme
    const list = $("program-list");
    if (list) {
      list.replaceChildren(...wedding.timeline.map((item) => {
        const li = el("li");
        li.append(el("span", "program-time", item.time), el("span", "program-dot"));
        const ev = el("span", "program-event", item.title);
        if (item.desc) ev.append(el("small", null, item.desc));
        li.append(ev);
        return li;
      }));
    }

    // dress code
    setText("dress-text", wedding.dressCode.text);
    const sw = $("swatches");
    if (sw) {
      sw.replaceChildren(...wedding.dressCode.palette.map((p) => {
        const li = el("li");
        li.style.background = p.color;
        li.title = p.name;
        li.setAttribute("aria-label", p.name);
        return li;
      }));
    }

    // gift + rsvp
    setText("gift-text", wedding.gift.text);
    const qr = $("gift-qr");
    if (qr) qr.src = wedding.gift.qrImage;
    setText("rsvp-text", wedding.rsvp.text);

    renderGallery();
  }

  /* Week (Mon–Sun) that contains the wedding day, with a hand-drawn heart on the day */
  function renderCalendar() {
    const box = $("calendar");
    if (!box) return;
    const [y, m, d] = wedding.date.iso.split("-").map(Number);
    const wedding_day = new Date(y, m - 1, d);
    const mondayOffset = (wedding_day.getDay() + 6) % 7;      // 0 = Monday
    const monday = new Date(y, m - 1, d - mondayOffset);

    const heads = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    const nodes = heads.map((h) => el("span", "cal-head", h));

    for (let i = 0; i < 7; i++) {
      const day = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
      const cell = el("span", "cal-day", String(day.getDate()).padStart(2, "0"));
      if (day.getTime() === wedding_day.getTime()) {
        cell.classList.add("is-wedding");
        cell.setAttribute("aria-label", `Ngày cưới ${wedding.date.display}`);
        cell.insertAdjacentHTML("beforeend",
          '<svg class="cal-heart" viewBox="0 0 40 36" aria-hidden="true">' +
          '<path d="M21 33 C 9 25 2 18 3 11 C 4 4 12 1 17 6 C 19 8 20 10 20 11 ' +
          'C 21 7 25 2 31 3 C 38 4 39 12 35 18 C 31 24 26 28 19 34"/></svg>');
      }
      nodes.push(cell);
    }
    box.replaceChildren(...nodes);
    setText("calendar-month", `${wedding.date.monthLabel}, ${y}`);
  }

  function renderGallery() {
    const grid = $("gallery-grid");
    const more = $("gallery-more");
    if (!grid) return;
    const { feature, photos, initialCount, spreads } = wedding.gallery;
    const alt = `Ảnh cưới ${wedding.couple.groomShort} và ${wedding.couple.brideShort}`;
    grid.classList.toggle("gallery--spreads", !!spreads);

    const imgs = [];
    if (feature) {
      const f = el("img", "is-feature");
      f.src = `assets/images/${feature}`;
      f.alt = alt;
      f.loading = "lazy";
      f.decoding = "async";
      imgs.push(f);
    }
    photos.forEach((file, i) => {
      const img = el("img", i >= initialCount ? "is-hidden" : null);
      img.src = `assets/images/${file}`;
      img.alt = `${alt} ${i + 1}`;
      img.loading = "lazy";
      img.decoding = "async";
      imgs.push(img);
    });
    grid.replaceChildren(...imgs);

    if (more) {
      more.hidden = photos.length <= initialCount;
      more.addEventListener("click", () => {
        grid.querySelectorAll("img.is-hidden").forEach((img) => img.classList.remove("is-hidden"));
        more.hidden = true;
      });
    }
  }

  /* ---------------- physical envelope timeline from the supplied opening prototype ---------------- */
  function initEnvelope() {
    const screen = $("env-screen");
    const button = $("env-open");
    const site = $("site");
    const music = $("background-music");
    const musicToggle = $("music-toggle");
    const stage = screen?.querySelector(".env-stage");
    const envelope = $("env");
    const card = $("env-card");
    const flap = $("env-flap");
    const body = $("env-body");
    const flapShade = $("flap-shade");
    const flapBackShade = $("flap-back-shade");
    const bodyShade = $("body-shade");
    const bodyBackShade = $("body-back-shade");
    const sealShadow = $("seal-shadow");
    const cardTop = $("card-top");
    const cardBottom = $("card-bottom");
    if (!screen || !button || !site || !stage || !envelope || !card || !flap || !body ||
      !flapShade || !flapBackShade || !bodyShade || !bodyBackShade || !sealShadow || !cardTop || !cardBottom) return;

    const bezier = (x1, y1, x2, y2) => {
      const cx = 3 * x1, bx = 3 * (x2 - x1) - cx, ax = 1 - cx - bx;
      const cy = 3 * y1, by = 3 * (y2 - y1) - cy, ay = 1 - cy - by;
      const sampleX = (t) => ((ax * t + bx) * t + cx) * t;
      const sampleY = (t) => ((ay * t + by) * t + cy) * t;
      const sampleDerivativeX = (t) => (3 * ax * t + 2 * bx) * t + cx;
      return (x) => {
        let t = x;
        for (let i = 0; i < 8; i++) {
          const error = sampleX(t) - x;
          const derivative = sampleDerivativeX(t);
          if (Math.abs(error) < 1e-6 || !derivative) break;
          t -= error / derivative;
        }
        return sampleY(Math.min(1, Math.max(0, t)));
      };
    };

    const ease = {
      out: bezier(.2, .6, .35, 1),
      inout: bezier(.45, 0, .55, 1),
      smooth: bezier(.42, 0, .75, .55),
      pullA: bezier(.5, 0, .75, .7),
      pullB: bezier(.3, .07, .6, 1),
      settle: bezier(.3, 0, .4, 1)
    };
    const timeline = {
      flap: [[0, 0], [600, 0], [4000, 180, "smooth"]],
      body: [[0, 0], [2200, 0], [5300, -180, "smooth"]]
    };
    const total = 5300;
    const CARD_HOLD_MS = 3500;   // "The Wedding Of" card stays on screen after the envelope opens
    const clamp01 = (value) => Math.min(1, Math.max(0, value));
    const track = (keys, time) => {
      if (time <= keys[0][0]) return keys[0][1];
      for (let i = 1; i < keys.length; i++) {
        const [endTime, endValue, easingName] = keys[i];
        const [startTime, startValue] = keys[i - 1];
        if (time <= endTime) {
          const progress = (time - startTime) / (endTime - startTime);
          const curve = ease[easingName || "inout"];
          return startValue + (endValue - startValue) * curve(progress);
        }
      }
      return keys[keys.length - 1][1];
    };

    let state = "closed";
    let frameId = 0;
    let startedAt = 0;

    function updateMusicToggle() {
      if (!musicToggle || !music) return;
      const muted = music.muted || music.volume === 0;
      musicToggle.textContent = muted ? "🔇" : "♫";
      musicToggle.classList.toggle("is-muted", muted);
      musicToggle.setAttribute("aria-pressed", String(muted));
      musicToggle.setAttribute("aria-label", muted ? "Bật nhạc nền" : "Tắt nhạc nền");
    }

    function startBackgroundMusic() {
      if (!music || music.muted || !music.paused) return;
      music.volume = .35;
      const playback = music.play();
      if (playback) playback.catch(() => {});
    }

    function fitPerspective() {
      const height = envelope.getBoundingClientRect().height || window.innerHeight;
      const perspective = height * 2;
      const cardDepth = height * .03;
      stage.style.perspective = `${perspective}px`;
      card.style.transform = `translateZ(${-cardDepth}px) scale(${(perspective + cardDepth) / perspective})`;
    }

    function renderAt(time) {
      const drift = ease.inout(clamp01(time / total));
      envelope.style.transform = `scale(${(1 + drift * .02).toFixed(4)})`;

      const flapAngle = track(timeline.flap, time);
      const flapProgress = clamp01((time - 600) / (4000 - 600));
      const flapWobble = Math.sin(flapProgress * Math.PI);
      flap.style.transform = `translateZ(${flapAngle > 90 ? -1 : 3}px) rotateX(${flapAngle}deg) rotateZ(${(flapWobble * .5).toFixed(3)}deg)`;
      const flapSin = Math.sin(Math.min(Math.abs(flapAngle), 180) * Math.PI / 180);
      flapShade.style.opacity = String(flapAngle < 90 ? .55 * flapSin : 0);
      flapBackShade.style.opacity = String(flapAngle > 90 ? .5 * flapSin : 0);
      const sealLow = flapAngle < 90 ? Math.sin(flapAngle * Math.PI / 180) * (1 - clamp01((flapAngle - 45) / 45)) : 0;
      sealShadow.style.opacity = String(.55 * sealLow);
      sealShadow.style.setProperty("--seal-shadow-y", `${52 + 5 * sealLow}%`);
      cardTop.style.opacity = String(.35 * flapSin);

      const bodyAngle = track(timeline.body, time);
      const bodyProgress = clamp01((time - 2200) / (5300 - 2200));
      const bodyWobble = Math.sin(bodyProgress * Math.PI);
      body.style.transform = `translateZ(${bodyAngle < -90 ? -2 : 1}px) rotateX(${bodyAngle}deg) rotateZ(${(bodyWobble * -.4).toFixed(3)}deg)`;
      const bodySin = Math.sin(Math.min(Math.abs(bodyAngle), 180) * Math.PI / 180);
      bodyShade.style.opacity = String(Math.abs(bodyAngle) < 90 ? .6 * bodySin : 0);
      bodyBackShade.style.opacity = String(Math.abs(bodyAngle) > 90 ? .5 * bodySin : 0);
      cardBottom.style.opacity = String(.35 * bodySin);
    }

    function revealInvitation() {
      if (state === "open") return;
      state = "open";
      site.hidden = false;
      document.body.classList.remove("is-locked");
      window.scrollTo(0, 0);
      button.setAttribute("aria-expanded", "true");
      initReveal();

      if (prefersReduced) {
        screen.hidden = true;
        return;
      }
      // crossfade the "The Wedding Of" card into the main invitation
      screen.classList.add("is-revealing");
      window.setTimeout(() => { screen.hidden = true; }, 920);
    }

    function tick(now) {
      if (!startedAt) startedAt = now;
      const elapsed = Math.min(now - startedAt, total);
      renderAt(elapsed);
      if (elapsed < total) frameId = window.requestAnimationFrame(tick);
      else window.setTimeout(revealInvitation, CARD_HOLD_MS);
    }

    function playOpening() {
      if (state !== "closed") return;
      startBackgroundMusic();
      state = "opening";
      button.disabled = true;
      if (prefersReduced) {
        revealInvitation();
        return;
      }
      startedAt = 0;
      window.cancelAnimationFrame(frameId);
      frameId = window.requestAnimationFrame(tick);
    }

    if (music) {
      music.volume = .35;
      music.addEventListener("volumechange", updateMusicToggle);
      startBackgroundMusic();
    }
    updateMusicToggle();
    musicToggle?.addEventListener("click", () => {
      if (!music) return;
      music.muted = !(music.muted || music.volume === 0);
      if (!music.muted) startBackgroundMusic();
      updateMusicToggle();
    });

    fitPerspective();
    renderAt(0);
    window.addEventListener("resize", fitPerspective, { passive: true });
    window.addEventListener("orientationchange", fitPerspective, { passive: true });
    button.addEventListener("click", playOpening);
  }

  /* ---------------- scroll reveal ---------------- */
  function initReveal() {
    const items = document.querySelectorAll(".reveal");
    if (prefersReduced || !("IntersectionObserver" in window)) {
      items.forEach((n) => n.classList.add("is-visible"));
      return;
    }
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -6% 0px" });
    items.forEach((n) => io.observe(n));
  }

  /* ---------------- RSVP ---------------- */
  function initRsvp() {
    const form = $("rsvp-form");
    const ok = $("rsvp-success");
    const err = $("rsvp-error");
    if (!form) return;

    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const data = new FormData(form);
      const name = String(data.get("name") || "").trim();
      const attend = data.get("attend");

      if (!name || !attend) {
        err.textContent = !name
          ? "Quý khách vui lòng nhập họ tên."
          : "Quý khách vui lòng chọn có tham dự hay không.";
        err.hidden = false;
        (!name ? form.elements.name : form.querySelector('input[name="attend"]')).focus();
        return;
      }
      err.hidden = true;

      // Chưa có backend: phản hồi chỉ hiển thị trên máy khách.
      // Muốn lưu thật, gửi `Object.fromEntries(data)` tới Google Sheets / form service tại đây.
      form.hidden = true;
      ok.hidden = false;
      ok.scrollIntoView({ behavior: prefersReduced ? "auto" : "smooth", block: "center" });
    });
  }

  document.addEventListener("DOMContentLoaded", () => {
    renderContent();
    initEnvelope();
    initRsvp();
  });
})();
