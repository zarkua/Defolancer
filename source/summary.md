# Machinations implementation summary

- `source/raw/sitemaps/` now contains fetched pages from:
  - `docs-sitemap.xml`
  - `static-pages-sitemap.xml`
  - `landing-pages-sitemap.xml`
- Fetch manifest:
  - `source/machinations_sitemap_index.md`
  - `source/machinations_sitemap_failures.md`
- Core implementation scaffold exists in `modules/machinations/*`:
  - normalized loader
  - headless tick-based simulation engine
  - delayed transfer queue
  - state/resource connections
  - end-condition checks
  - batch-run Monte Carlo style analytics
- Current implementation scope and schema:
  - `source/machinations_kernel_mvp.md`
