const test = require('tape');
const util = require('util');
const { ZSTDDecoder } = require('./');

const { TextDecoder } = typeof window === 'undefined' ? util : window;

const TEXT_TEST_ZSTD = new Uint8Array([
	40,		181,	47,		253,	36,		13,		105,
	0,		0,		104,	101,	108,	108,	111,
	32,		119,	111,	114,	108,	100,	33,
	10,		154,	39,		191,	122
]);

test('zstddec', async (t) => {
	const zstd = new ZSTDDecoder();
	await zstd.init();
	
	const data_k = zstd.decode(TEXT_TEST_ZSTD, 13);
	let text = new TextDecoder().decode(data_k);
	t.equals(text, 'hello world!\n', 'Decodes Text : Size Known');
	
	const data_u = zstd.decode(TEXT_TEST_ZSTD, 0);
	text = new TextDecoder().decode(data_u);
	t.equals(text, 'hello world!\n', 'Decodes Text : Size Unknown');
	
	t.end();
});