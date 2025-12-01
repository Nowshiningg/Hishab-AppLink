// sqflite web worker setup
// This file is required for sqflite_common_ffi_web to work

importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.js');

// Initialize SQLite
self.addEventListener('message', async (event) => {
  if (event.data && event.data.type === 'init') {
    try {
      const SQL = await initSqlJs({
        locateFile: file => `https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/${file}`
      });
      self.postMessage({ type: 'ready' });
    } catch (error) {
      self.postMessage({ type: 'error', error: error.message });
    }
  }
});
