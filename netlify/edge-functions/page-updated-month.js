// Keeps the "Page updated <Month> <Year>" line on every page showing the
// current month in Sydney, so it rolls over on the 1st of each month without
// a rebuild. The layouts hold the same line as a fallback.

const LABEL = /Page updated [A-Z][a-z]+ \d{4}/g;

export default async (request, context) => {
  const response = await context.next();
  const type = response.headers.get("content-type") || "";
  if (!type.includes("text/html")) return response;

  const month = new Intl.DateTimeFormat("en-AU", {
    month: "long",
    year: "numeric",
    timeZone: "Australia/Sydney",
  }).format(new Date());

  const html = await response.text();
  if (!LABEL.test(html)) {
    return new Response(html, response);
  }
  LABEL.lastIndex = 0;
  const headers = new Headers(response.headers);
  headers.delete("content-length");
  headers.delete("etag");
  return new Response(html.replace(LABEL, `Page updated ${month}`), {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
};

export const config = {
  path: "/*",
  excludedPath: [
    "/assets/*",
    "/*.css",
    "/*.js",
    "/*.json",
    "/*.xml",
    "/*.txt",
    "/*.jpg",
    "/*.jpeg",
    "/*.png",
    "/*.webp",
    "/*.gif",
    "/*.svg",
    "/*.ico",
    "/*.pdf",
  ],
};
