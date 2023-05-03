module.exports = {
    // Remove trailing slashes
    permalink: (data) =>
      data.permalink
        ? data.permalink
        : data.page.outputFileExtension === "html" && data.page.filePathStem
        ? `${data.page.filePathStem}.html`
        : "",
  };