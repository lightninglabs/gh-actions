import * as context from '../src/context';

describe('getInputList', () => {
  it('handles single line correctly', async () => {
    await setInput('foo', 'bar');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar']);
  });

  it('handles multiple lines correctly', async () => {
    setInput('foo', 'bar\nbaz');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar', 'baz']);
  });

  it('remove empty lines correctly', async () => {
    setInput('foo', 'bar\n\nbaz');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar', 'baz']);
  });

  it('handles comma correctly', async () => {
    setInput('foo', 'bar,baz');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar', 'baz']);
  });

  it('remove empty result correctly', async () => {
    setInput('foo', 'bar,baz,');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar', 'baz']);
  });

  it('handles different new lines correctly', async () => {
    setInput('foo', 'bar\r\nbaz');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar', 'baz']);
  });

  it('handles different new lines and comma correctly', async () => {
    setInput('foo', 'bar\r\nbaz,bat');
    const res = await context.getInputList('foo');
    console.log(res);
    expect(res).toEqual(['bar', 'baz', 'bat']);
  });

  it('handles multiple lines and ignoring comma correctly', async () => {
    setInput('driver-opts', 'image=moby/buildkit:master\nnetwork=host');
    const res = await context.getInputList('driver-opts', true);
    console.log(res);
    expect(res).toEqual(['image=moby/buildkit:master', 'network=host']);
  });

  it('handles different new lines and ignoring comma correctly', async () => {
    setInput('driver-opts', 'image=moby/buildkit:master\r\nnetwork=host');
    const res = await context.getInputList('driver-opts', true);
    console.log(res);
    expect(res).toEqual(['image=moby/buildkit:master', 'network=host']);
  });
});

describe('asyncForEach', () => {
  it('executes async tasks sequentially', async () => {
    const testValues = [1, 2, 3, 4, 5];
    const results: number[] = [];

    await context.asyncForEach(testValues, async value => {
      results.push(value);
    });

    expect(results).toEqual(testValues);
  });
});

// See: https://github.com/actions/toolkit/blob/master/packages/core/src/core.ts#L67
function getInputName(name: string): string {
  return `INPUT_${name.replace(/ /g, '_').toUpperCase()}`;
}

function setInput(name: string, value: string): void {
  process.env[getInputName(name)] = value;
}
