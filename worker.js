export default {
  async fetch(request, env) {
    const ua = request.headers.get('user-agent') || '';
    const isCurl = /curl|wget/i.test(ua);
    const url = new URL(request.url);

    // Serve shell script for curl/wget at root
    if (isCurl && url.pathname === '/') {
      const script = await env.ASSETS.fetch(new URL('/install.sh', url.origin));
      return new Response(await script.text(), {
        headers: { 'content-type': 'text/plain; charset=utf-8' }
      });
    }

    // Serve index.html for root path in browsers
    if (url.pathname === '/') {
      return env.ASSETS.fetch(new URL('/index.html', url.origin));
    }

    return env.ASSETS.fetch(request);
  }
}
