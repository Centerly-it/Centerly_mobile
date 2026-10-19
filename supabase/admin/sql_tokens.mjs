// Canonical comparison of CLI migration history, ignoring outer comments/spacing.
// Dollar/string bodies remain exact (with LF line endings), never executed here.
export function sqlTokens(source) {
  const sql=source.replaceAll('\r\n','\n'), tokens=[];
  let i=0;
  while(i<sql.length) {
    if(/\s/.test(sql[i])||sql[i]===';') { i++; continue; }
    if(sql.startsWith('--',i)) { const end=sql.indexOf('\n',i); i=end<0?sql.length:end; continue; }
    if(sql.startsWith('/*',i)) {
      let depth=1; i+=2;
      while(i<sql.length&&depth) {
        if(sql.startsWith('/*',i)) {depth++;i+=2;}
        else if(sql.startsWith('*/',i)) {depth--;i+=2;}
        else i++;
      }
      if(depth) throw new Error('Unterminated SQL comment');
      continue;
    }
    const dollar=sql.slice(i).match(/^\$(?:[A-Za-z_][A-Za-z_0-9]*)?\$/)?.[0];
    if(dollar) {
      const end=sql.indexOf(dollar,i+dollar.length);
      if(end<0) throw new Error('Unterminated SQL dollar body');
      tokens.push(sql.slice(i,end+dollar.length)); i=end+dollar.length; continue;
    }
    if(sql[i]==="'"||sql[i]==='"') {
      const start=i,quote=sql[i++]; let closed=false;
      while(i<sql.length) {
        if(sql[i++]===quote) {
          if(sql[i]===quote) {i++;continue;}
          closed=true;break;
        }
      }
      if(!closed) throw new Error('Unterminated SQL quote');
      tokens.push(sql.slice(start,i));continue;
    }
    const word=sql.slice(i).match(/^[A-Za-z_0-9]+/)?.[0];
    if(word) { tokens.push(word.toLowerCase()); i+=word.length; }
    else tokens.push(sql[i++]);
  }
  return tokens;
}
