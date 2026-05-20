const [major, minor] = process.version.slice(1).split('.').map(Number);

if (major < 20 || (major === 20 && minor < 9)) {
  console.error(
    `\nNode.js >= 20.9.0 is required (current: ${process.version}).\n` +
      'Next.js 16 will not build on older versions.\n\n' +
      'Fix (pick one):\n' +
      '  nvm:  cd frontend && nvm install && nvm use\n' +
      '  brew: brew install node@20\n' +
      '        export PATH="$(brew --prefix node@20)/bin:$PATH"\n' +
      '  fnm:  fnm install && fnm use\n'
  );
  process.exit(1);
}
