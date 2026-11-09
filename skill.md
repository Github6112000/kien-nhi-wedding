# Skill: Luxury Botanical Wedding Invitation --- Blue & Ivory Interactive Web Invite

## Purpose

Create a premium mobile-first digital wedding invitation inspired by the
supplied reference video.

The target experience is an elegant editorial wedding website presented
primarily on a smartphone. The visual language combines warm ivory
paper, deep/navy blue botanical illustrations, fine serif typography,
restrained micro-animation, and an envelope-opening interaction.

This skill is for generating the **design and implementation
specification** for an AI coding/design agent. The output should be a
real responsive web invitation, not a static poster.

## Core Creative Direction

Keywords:

-   editorial wedding stationery
-   European / Italian garden wedding
-   ivory handmade paper
-   hand-painted blue botanical florals
-   dark navy accents
-   refined serif typography
-   delicate line illustrations
-   quiet luxury
-   generous whitespace
-   tactile paper feel
-   slow, graceful motion
-   mobile-first invitation

Do not turn the design into a generic blue wedding template. The
dominant impression must be **ivory paper + monochrome blue botanical
artwork + high-end serif editorial typography**.

Avoid:

-   gradients that look digital or glossy
-   neon colors
-   excessive shadows
-   rounded SaaS-style cards
-   generic sans-serif-heavy layouts
-   excessive animation
-   crowded information density
-   decorative elements unrelated to the botanical stationery theme

## Reference Experience

The reference video shows a phone displaying an interactive wedding
invitation.

The approximate sequence is:

1.  Closed ivory envelope with a large satin bow.
2.  Bow disappears / envelope opens.
3.  Floral stationery is revealed.
4.  Couple's names appear in a centered invitation card.
5.  Wedding date and introductory invitation text.
6.  Location section.
7.  Map / venue information.
8.  Wedding-day timeline.
9.  Dress-code / formal-elegance section.
10. Gift section.
11. RSVP section with a copyable code or form action.
12. FAQ / frequently asked questions.
13. Closing section with the couple's names.
14. Minimal ending.

The user should be able to scroll naturally through the invitation after
the opening interaction.

## Visual System

### Color palette

Use a restrained palette:

-   `#F7F2E8` --- warm ivory / paper
-   `#EFE7D8` --- secondary paper tone
-   `#172A52` --- deep navy blue
-   `#243A68` --- botanical blue
-   `#8B8A83` --- muted gray text
-   `#FFFFFF` --- controlled white space

The exact colors may be adjusted slightly to match supplied floral
artwork, but keep the palette low-saturation and sophisticated.

### Typography

Use an elegant high-contrast serif as the primary display typeface.

Suitable direction:

-   Cormorant Garamond
-   Playfair Display
-   DM Serif Display
-   Libre Baskerville

Use a restrained sans-serif for small utility text:

-   Inter
-   Manrope
-   Montserrat

Typography hierarchy:

-   Couple names: large editorial serif, approximately 34--52px on
    mobile.
-   Major section titles: 28--42px serif.
-   Small labels: 9--12px uppercase with generous letter spacing.
-   Body: 12--16px, relaxed line height.
-   Date numerals: large, thin, widely spaced.
-   Buttons: compact uppercase sans-serif with tracking.

Never use more than two type families.

## Botanical Artwork

The floral artwork is one of the most important parts of the visual
identity.

Use hand-painted / watercolor botanical illustrations in monochrome
blue.

Preferred composition:

-   flowers concentrated around edges and corners
-   central negative space reserved for text
-   asymmetrical botanical clusters
-   leaves and stems extending organically inward
-   no thick vector outlines
-   no photorealistic flowers
-   no saturated multicolor bouquet

If image generation is available, generate reusable transparent PNG/SVG
botanical assets.

Prompt direction for floral assets:

> delicate hand-painted botanical wedding flowers, monochrome indigo and
> cornflower blue watercolor, vintage European wedding stationery, fine
> botanical detail, ivory paper aesthetic, transparent background,
> elegant asymmetrical floral border, no text, no frame

Create separate assets where useful:

-   `floral-top`
-   `floral-bottom`
-   `floral-corner-left`
-   `floral-corner-right`
-   `floral-full-border`
-   small botanical sprigs
-   tiny blue line-art wedding icons

## Envelope Opening

The first screen should feel like opening a physical wedding invitation.

### Initial state

Full viewport:

-   warm ivory background
-   centered vertical envelope
-   envelope approximately 72--84% of mobile viewport width
-   subtle paper texture
-   triangular flap
-   thin gold/beige construction lines
-   large pale gray / champagne satin bow
-   small elegant text on the envelope
-   no busy UI

### Interaction

On tap/click:

1.  The bow gently scales/fades.
2.  Envelope flap rotates upward.
3.  Inner floral card becomes visible.
4.  The envelope sides subtly separate.
5.  The invitation card moves forward.
6.  Crossfade into the first invitation section.

Animation should take approximately 1.2--1.8 seconds.

Use CSS transforms and opacity where possible. Keep motion smooth and
physically plausible.

Do not use a dramatic 3D effect that makes the invitation look like a
game.

Respect `prefers-reduced-motion`.

## Navigation

After opening, provide a minimal top navigation.

Reference style:

-   deep navy horizontal header
-   tiny circular monogram/logo at left
-   minimal hamburger/menu control at right
-   small centered brand/domain label when appropriate

Navigation should remain visually quiet.

Possible menu items:

-   Invitation
-   Details
-   Location
-   Timeline
-   Dress Code
-   Gift
-   RSVP
-   FAQ

Use anchor scrolling rather than unnecessary page reloads.

## Page Structure

### Section 01 --- Hero / Invitation

Composition:

-   ivory paper background
-   large blue floral border
-   centered white/ivory invitation card
-   couple initials or small monogram
-   `SAVE THE DATE` or equivalent micro-label
-   couple names
-   date
-   short invitation sentence

Keep the central card visually dominant.

Example structure:

``` text
[monogram]

SAVE THE DATE

LAURA
&
MARCO

19 · 06 · 2027

With joy, we invite you
to celebrate our wedding
```

Names and dates are placeholders only. Never hard-code reference names
unless the user provides them.

### Section 02 --- Date

Use an editorial date treatment.

Example:

``` text
THE DAY

SATURDAY
19 JUNE 2027

Ceremony begins at 4:00 PM
```

The date can be broken into individual numerals with generous spacing.

Add a very small botanical or line-art illustration.

### Section 03 --- Location

Use large whitespace and precise hierarchy:

``` text
LOCATION

Villa Carlotta
4:00 PM

Via ...
Lake ...
```

Include:

-   venue
-   address
-   city/country
-   optional ceremony/reception distinction
-   `OPEN IN MAPS` button

### Section 04 --- Map

Embed a real map only if the implementation environment permits it.

Otherwise create a clean map placeholder with:

-   pale map background
-   one or two route markers
-   blue location pin
-   venue label
-   compact `OPEN IN MAPS` button

Do not make the map visually dominant.

### Section 05 --- Wedding Day Timeline

Create a vertical editorial timeline.

Example:

``` text
THE DAY

04:00 PM
Guest arrival

04:30 PM
Ceremony

06:00 PM
Cocktail hour

07:30 PM
Dinner & celebration
```

Use very thin dividers and small botanical ornaments.

Avoid large timeline cards.

### Section 06 --- Dress Code

Heading direction:

``` text
Formal
elegance
```

Add a very small line-art fashion / couple illustration.

Supporting copy should be short.

Example:

``` text
We kindly ask our guests
to dress in formal attire.
```

### Section 07 --- Gift

Keep this section understated.

Example:

``` text
A gift for us

Your presence is the greatest gift,
but if you wish to celebrate with us,
we have included our details below.
```

If bank/payment details are supplied, show them in a restrained bordered
paper panel with a copy button.

Never expose sensitive payment information unless the user explicitly
provides it.

### Section 08 --- RSVP

Use a clean form.

Fields can include:

-   Name
-   Attendance
-   Number of guests
-   Dietary requirements
-   Message

Primary CTA:

`SEND RSVP`

Button styling:

-   deep navy
-   white text
-   compact rectangular shape
-   minimal border radius or none

Show a success state after submission.

### Section 09 --- FAQ

Use an accordion.

Questions may include:

-   What should I wear?
-   Can I bring a guest?
-   Is there parking?
-   What time should I arrive?
-   Where should I stay?

Keep the accordion typography editorial and minimal.

### Section 10 --- Closing

Return to maximum whitespace.

Use:

``` text
With love,

LAURA
&
MARCO

We can't wait to celebrate with you.
```

Add a small blue botanical illustration.

## Animation System

Animation should communicate physical stationery rather than flashy web
UI.

Preferred transitions:

-   fade + translateY 12--24px
-   slow floral reveal
-   envelope flap rotation
-   card scale from `0.97` to `1`
-   subtle image parallax
-   section elements reveal as they enter viewport

Recommended timing:

-   micro interaction: 200--350ms
-   text reveal: 500--800ms
-   major section transition: 700--1200ms
-   envelope opening: 1200--1800ms

Use easing such as:

``` css
cubic-bezier(0.22, 1, 0.36, 1)
```

Do not animate every element independently.

## Scroll Behavior

The reference experience is fundamentally vertical and mobile-first.

Recommended:

-   `scroll-behavior: smooth`
-   generous section padding
-   approximately 85--100svh for major editorial sections
-   shorter sections for map, timeline, RSVP and FAQ
-   sticky navigation only after the envelope has been opened

On desktop, center the invitation inside a narrow editorial column
rather than stretching content across the entire viewport.

Recommended maximum content width:

``` text
420–520px
```

The design should still feel like a premium mobile invitation when
viewed on a desktop browser.

## Paper Texture

The background should not be perfectly flat.

Use a very subtle paper texture or noise layer:

-   opacity approximately 0.02--0.06
-   very fine grain
-   no visible repeating pattern
-   no strong vignette

If no texture asset exists, use a CSS-generated noise approach only if
it does not noticeably increase rendering cost.

## Borders and Decorative Rules

Use extremely thin rules:

``` css
border-width: 0.5px–1px;
```

Preferred border color:

-   low-opacity navy
-   warm beige
-   muted gray

Use ornamental lines around cards sparingly.

Avoid thick frames.

## Buttons

Buttons should resemble stationery labels rather than modern application
controls.

Preferred:

``` text
OPEN IN MAPS
SEND RSVP
COPY
```

Style:

-   uppercase
-   9--11px
-   letter-spacing: 0.12--0.18em
-   dark navy fill for primary actions
-   ivory background for secondary actions
-   compact rectangular dimensions

## Responsive Requirements

Primary target:

-   375 × 812
-   390 × 844
-   412 × 915

Secondary target:

-   768px tablet
-   1440px desktop

The invitation must never require horizontal scrolling.

Use `100svh` rather than relying only on `100vh`.

Protect content from:

-   iPhone safe areas
-   browser address bar changes
-   mobile Safari viewport behavior
-   dynamic browser chrome

## Accessibility

The generated implementation must include:

-   semantic headings
-   proper button labels
-   keyboard navigation
-   visible focus states
-   sufficient text contrast
-   alt text for meaningful botanical images
-   `prefers-reduced-motion`
-   form labels
-   accessible accordion controls

Do not make the invitation dependent on animation to understand the
content.

## Performance

Prefer:

-   compressed WebP/AVIF imagery
-   SVG for simple line art
-   lazy-loaded non-critical images
-   CSS transforms for animation
-   no large video background
-   minimal JavaScript
-   no unnecessary animation libraries

The envelope opening should work smoothly on mid-range mobile hardware.

## Content Model

Do not hard-code content throughout the UI.

Use a central data object such as:

``` js
const wedding = {
  couple: {
    personA: "Laura",
    personB: "Marco"
  },

  date: {
    iso: "2027-06-19",
    display: "19 June 2027"
  },

  ceremony: {
    time: "4:00 PM",
    venue: "Villa Carlotta",
    address: "..."
  },

  reception: {
    venue: "...",
    address: "..."
  },

  timeline: [
    { time: "4:00 PM", title: "Guest arrival" },
    { time: "4:30 PM", title: "Ceremony" },
    { time: "6:00 PM", title: "Cocktail hour" },
    { time: "7:30 PM", title: "Dinner & celebration" }
  ],

  dressCode: {
    title: "Formal elegance",
    description: "..."
  },

  gift: {
    description: "...",
    accountName: "...",
    accountNumber: "..."
  },

  rsvp: {
    deadline: "...",
    endpoint: "..."
  }
};
```

The AI must replace these values with user-provided wedding information.

## Implementation Guidance

If building with React/Next.js:

Recommended component structure:

``` text
WeddingInvitation
├── EnvelopeIntro
├── SiteHeader
├── HeroInvitation
├── DateSection
├── LocationSection
├── MapSection
├── TimelineSection
├── DressCodeSection
├── GiftSection
├── RSVPSection
├── FAQSection
└── ClosingSection
```

Recommended state:

``` text
isEnvelopeOpen
rsvpStatus
activeFAQ
```

Use Intersection Observer or an equivalent mechanism for
scroll-triggered reveals.

Do not introduce a global state-management library for this invitation
unless the surrounding application already requires one.

## Design QA Checklist

Before finalizing, verify:

-   The first screen looks like a physical ivory wedding envelope.
-   The bow is visually soft and premium.
-   Opening the envelope feels natural.
-   Blue botanical artwork dominates the decorative language.
-   Couple names remain the strongest typographic element.
-   The page has substantial negative space.
-   No section looks like a generic SaaS dashboard.
-   Typography feels editorial rather than corporate.
-   All sections are usable with one hand on a mobile phone.
-   Map and RSVP actions work.
-   Copy buttons provide clear feedback.
-   Text remains readable over botanical artwork.
-   Animation is subtle and can be disabled.
-   Desktop layout preserves the narrow invitation character.
-   No horizontal overflow occurs.
-   Placeholder content is clearly replaced before production.

## AI Generation Prompt

When this skill is invoked, instruct the implementation agent:

> Build a premium mobile-first digital wedding invitation inspired by
> luxury European botanical stationery.
>
> Use a warm ivory paper background, deep navy monochrome watercolor
> florals, elegant high-contrast serif typography, thin editorial rules,
> generous negative space and restrained micro-interactions.
>
> Begin with an interactive physical-looking ivory envelope tied with a
> pale satin bow. On interaction, animate the bow and envelope flap
> opening to reveal the floral invitation.
>
> Continue into a vertically scrollable wedding website containing the
> couple's names, wedding date, venue, map, day timeline, dress code,
> gift information, RSVP form, FAQ and closing message.
>
> The result must feel like a premium printed invitation translated into
> a refined digital experience, not like a conventional website
> template.
>
> Make all wedding information data-driven so the names, dates, venues,
> text, RSVP details and imagery can be replaced without changing
> component structure.
>
> Prioritize visual fidelity, typography, spacing, botanical composition
> and animation quality. Keep the implementation lightweight, responsive
> and accessible.

## Output Contract

When asked to create the invitation, the AI should produce:

1.  A complete responsive implementation.
2.  A reusable wedding data/config object.
3.  Required floral and decorative assets or clear asset-generation
    prompts.
4.  Envelope opening animation.
5.  All invitation sections listed above.
6.  Working navigation, map action, copy action, RSVP form and FAQ
    interaction where applicable.
7.  Mobile-first styling matching the reference aesthetic.
8.  A short list of values the user must replace before publishing.

Do not output only a visual mockup description when the user asks for
the actual invitation. Produce the implementation.
