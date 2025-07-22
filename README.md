# The Kai Way

Personal blog built with Hugo.

## Development

```bash
# Install Hugo (if not already installed)
brew install hugo

# Start development server
hugo server -D

# Build site
hugo
```

## Structure

- `content/` - Content files (Markdown)
  - `posts/` - Blog posts
  - `about.md` - About page
  - `archive.md` - Archive page
- `layouts/` - Hugo templates
- `static/` - Static assets (CSS, JS, images)
- `public/` - Generated site (do not edit)

## Configuration

See `hugo.toml` for site configuration.

## URLs

All existing URLs are preserved:
- Blog posts: `/:year/:month/:day/:slug/`
- RSS feed: `/atom.xml`
- JSON feed: `/feed.json`