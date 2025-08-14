// Para esse exercício aprendi a:
//    Ctrl + d = EOF (End-of-File)
//    Como typescript funciona com as libs do node/javascript
//    Funcionamento process.stdin

process.stdin.resume();

process.stdin.setEncoding('utf8');

let input = '';

process.stdin.on('data', (chunk) => {
  input += chunk; // Toda vez que aperto o 'enter' ao colocar um numero, ele entra aqui e adiciona
});

process.stdin.on('end', () => { // entra nessa funcao após o EOF
  const lines = input.trim().split('\n'); 
  const [a, b] = lines.map((x) => parseInt(x)); // Converte todas as linhas para número
  const sum = (a ?? 0) + (b ?? 0);

  console.log(`X = ${sum}`);
});
