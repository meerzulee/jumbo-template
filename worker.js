export default {
  async fetch(request, env) {
    const ua = request.headers.get('user-agent') || '';
    const isCurl = /curl|wget/i.test(ua);
    const pathname = new URL(request.url).pathname;

    // Serve shell script for curl/wget at root
    if (isCurl && pathname === '/') {
      const script = await env.ASSETS.fetch(new Request('https://dummy/install.sh'));
      return new Response(await script.text(), {
        headers: { 'content-type': 'text/plain; charset=utf-8' }
      });
    }

    return env.ASSETS.fetch(request);
  }
}
