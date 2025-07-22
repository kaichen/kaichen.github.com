# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal blog built with Hugo static site generator. The site was migrated from 11ty to Hugo while preserving all existing URLs and functionality.

## Commands

### Development
```bash
# Start development server (runs on http://localhost:1313)
hugo server -D

# Build site for production (outputs to public/)
hugo

# Build with verbose output
hugo -v
```

## Architecture

### Content Structure
- Blog posts are in `content/posts/` with Jekyll-style naming: `YYYY-MM-DD-title.md`
- Each post requires front matter with: `date`, `title`, `slug`, and optional `tags`
- Special pages: `/series/` and `/inspect-rails/` are separate content files

### URL Structure
The site maintains backward compatibility with the original URL structure:
- Blog posts: `/:year/:month/:day/:slug/`
- Categories: `/blog/categories/:category/`
- RSS feed: `/atom.xml` (not default Hugo `/index.xml`)
- JSON feed: `/feed.json`

### Template Hierarchy
- `layouts/_default/baseof.html` - Base template for all pages
- `layouts/index.html` - Homepage template
- `layouts/posts/single.html` - Individual blog post template
- `layouts/_default/archive.html` - Archive page listing all posts by year
- `layouts/_default/series.html` - Series page showing posts tagged with "series"

### Configuration Notes
- Taxonomies are configured to output at `/blog/categories/` instead of Hugo's default `/tags/`
- RSS output is configured to generate at `/atom.xml` with `baseName = "atom"`
- Pagination is set to 8 posts per page
- Disqus comments and Umami analytics are integrated

### Migration Context
This site was migrated from 11ty, important considerations:
- All existing URLs must be preserved
- The `public/` directory should not be committed (add to .gitignore)
- Legacy 11ty files have been removed but some `.njk` files may remain in content/
- Post dates in filenames are authoritative - front matter dates should match