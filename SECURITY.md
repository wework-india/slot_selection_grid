# Security Policy

## Supported versions

This package follows [Semantic Versioning](https://semver.org/). Security
fixes are applied to the latest published minor release only. Upgrade to the
most recent version before reporting an issue.

| Version | Supported |
| ------- | --------- |
| 0.2.x   | Yes       |
| < 0.2   | No        |

## Reporting a vulnerability

**Do not open a public GitHub issue for a security vulnerability.**

Report it privately through either channel:

1. **GitHub Security Advisories** — use
   [Report a vulnerability](https://github.com/wework-india/slot_selection_grid/security/advisories/new)
   on this repository. This is the preferred route.
2. **Email** — developer@wework.co.in

Please include:

- A description of the vulnerability and its impact
- Steps to reproduce, or a minimal proof of concept
- The package version and Flutter version affected
- Any suggested mitigation

## What to expect

- **Acknowledgement** within 5 business days.
- **Initial assessment** within 10 business days, including whether we consider
  it a vulnerability and an expected timeline.
- **Disclosure** coordinated with you. We'll credit you in the advisory and
  CHANGELOG unless you'd prefer to stay anonymous.

Please give us a reasonable opportunity to release a fix before disclosing
publicly.

## Scope

This is a UI widget package with no network calls, no persistence, no platform
channels, and no runtime dependencies beyond the Flutter SDK. The realistic
security surface is small, but we're interested in reports of:

- Crashes or unbounded resource consumption reachable from caller-supplied
  `dates`, `timeSlots`, or `slotStates` input
- Unintended exposure of data passed through builder callbacks
- Supply-chain concerns about the published package contents

Issues in *your* application's handling of booking data are out of scope — this
package renders a grid and reports taps; it does not store, transmit, or
validate anything.
