/* Essa forma eu pensei originalmente
process.stdin.on('data', entrada => {
   const PI: number = 3.14159;
   let numero = parseFloat(entrada); 
   const saida = PI * Math.pow(numero, 2);
   console.log(`A=${saida.toFixed(4)}`);
   process.exit();
});
*/
process.stdin.resume();

process.stdin.setEncoding('utf8');


let inputCompleto = ''; 

process.stdin.on('data', chunk => {
  inputCompleto += chunk;
});

process.stdin.on('end', () => {
  const PI = 3.14159;

  const raio = parseFloat(inputCompleto.trim());

  if (!isNaN(raio)) {
    const area = PI * Math.pow(raio, 2);
    console.log(`A=${area.toFixed(4)}`);
  }
});
