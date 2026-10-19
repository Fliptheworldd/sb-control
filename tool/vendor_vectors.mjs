// Execute only named public UI functions in an isolated VM with a mocked GATT
// characteristic. Input files are fetched separately from the manufacturer.
// No vendor source is included in SB CONTROL or sent to any device.
import fs from 'node:fs';
import vm from 'node:vm';
import crypto from 'node:crypto';
import path from 'node:path';
const input = process.argv[2];
if (!input) throw Error('Usage: node tool/vendor_vectors.mjs /path/to/vendor/js');
const source = Object.fromEntries(['main.js','qvap.js','crafty.js','volcano.js'].map(n=>[n,fs.readFileSync(path.join(input,n),'utf8')]));
function extract(text, name) {
  const start=text.indexOf('function '+name+'(');
  if(start<0) throw Error('Vendor function missing: '+name);
  const brace=text.indexOf('{',start); let level=1, quote=null, escape=false;
  for(let i=brace+1;i<text.length;i++) {
    const ch=text[i];
    if(quote) { if(escape){escape=false;continue;} if(ch==='\\'){escape=true;continue;} if(ch===quote)quote=null;continue; }
    if(ch==='"'||ch==="'"||ch==='`'){quote=ch;continue;}
    if(ch==='{')level++; if(ch==='}'&&--level===0)return text.slice(start,i+1);
  }
  throw Error('Unclosed vendor function');
}
const out=[];
async function capture(file, name, args, expectedId, overrides={}) {
  const writes=[];
  const character=(id)=>({writeValue:async b=>{writes.push({id,bytes:Array.from(new Uint8Array(b))});}});
  const no=()=>{};
  const ctx={console:{log:no},ArrayBuffer,DataView,Uint8Array,
    devices:{Crafty:1,Hybrid:2,Veazy:3,Venty:4}, whichDeviceConnected:()=>file==='crafty.js'?1:2,
    isDeviceConnectedVeazyVenty:()=>true,isBleProcessPendingWithoutAlert_Repeat:()=>false,
    setBleProcessPending:no,generateErrorMsg:(s)=>{throw Error(s)},showError:(e)=>{throw e},
    setTemperatureWillChangeViaBLE_RESET:no,boostWillChangeViaBLE_RESET:no,superboostWillChangeViaBLE_RESET:no,
    getSuperBoostModeMobile:()=>false,getBoostModeMobile:()=>false,
    convertToUInt16BLE:n=>new Uint16Array([n]).buffer,convertToUInt32BLE:n=>new Uint32Array([n]).buffer,convertToUInt8BLE:n=>new Uint8Array([n]).buffer,
    maskSetTemperatureWrite:2,maskSetBoostWrite:4,maskSetSuperboostWrite:8,maskHeaterWrite:32,maskSettingsWrite:128,
    characteristicQvap:character('qvap'),characteristicWriteTempV:character('hybrid.target'),
    characteristicWriteTemp:character('crafty.target'),characteristicWriteBoostTemp:character('crafty.boost'),BOOSTTEMP:15,
    oldCraftyFirmware:false,characteristicIsCraftyOn:false,characteristicHeaterOn:character('crafty.on'),characteristicHeaterOff:character('crafty.off'),showCraftyActive:no,
    isVolcanoOn:false,characteristicHeaterOnV:character('hybrid.on'),characteristicHeaterOffV:character('hybrid.off'),setVisualVolcanoActive:no,
    isPumpOnVolcano:false,characteristicVolcanoPumpOn:character('hybrid.pumpOn'),characteristicIsPumpOffV:character('hybrid.pumpOff'),setVisualStatePumpVolcano:no,
    heaterModusPrev:0,brightness:{value:7},limitValueToRange:(v,a,b)=>Math.max(a,Math.min(b,v)),vibrationToggle:{checked:true},
    ...overrides};
  vm.createContext(ctx);
  for(const helper of ['convertToUInt8BLE','convertToUInt16BLE','convertToUInt32BLE']) {
    vm.runInContext(extract(source['main.js'],helper),ctx,{timeout:1000});
  }
  vm.runInContext(extract(source[file],name),ctx,{timeout:1000});
  ctx[name](...args); await new Promise(resolve=>setImmediate(resolve));
  if(!writes.length)throw Error('No vendor write: '+name);
  out.push({case:expectedId,source:file,function:name,args,writes});
}
await capture('qvap.js','writeSollTemperatureQVap',[185],'q.target185');
await capture('qvap.js','writeBoostTemperatureQVap',[15],'q.boost15');
await capture('qvap.js','writeSuperBoostTemperatureQVap',[20],'q.superboost20');
await capture('qvap.js','onHeatClickQvap',[],'q.heatOn');
await capture('qvap.js','onHeatClickQvap',[],'q.heatOff',{heaterModusPrev:1});
await capture('qvap.js','writeBrightnessQvap',[7],'q.brightness7');
await capture('qvap.js','vibrationToggleHandlerQvap',[],'q.vibrationOn');
for (const on of [true,false]) {
  await capture('qvap.js','boostSuperboostTimeoutFuncQvap',[],`q.permanentBoost.${on}`,{boostSuperBoostTimeoutToggle:{checked:on}});
  for (const [model,id] of [['venty',4],['veazy',3]]) {
    await capture('qvap.js','boostVisualizationFunc',[],`q.visualization.${model}.${on}`,{whichDeviceConnected:()=>id,boostVisualizationToggle:{checked:on},BIT_SETTINGS_BOOST_VISUALIZATION:64});
  }
}
await capture('qvap.js','startFactoryResetFuncQVap',[],'q.reset',{BIT_SETTINGS_FACTORY_RESET:4,QVapReadBrightnessAndVibration:()=>{},setShowSollTempMobile:()=>{}});
await capture('qvap.js','startAnalysisQvapFunc',[],'q.analysis');
await capture('crafty.js','writeSollTemperatureCrafty',[185],'crafty.target185');
await capture('crafty.js','writeBoostTemperatureCrafty',[15],'crafty.boost15');
await capture('crafty.js','onHeatClickCrafty',[],'crafty.heatOn');
await capture('crafty.js','onHeatClickCrafty',[],'crafty.heatOff',{characteristicIsCraftyOn:true});
await capture('volcano.js','writeSollTemperatureHybrid',[185],'hybrid.target185');
await capture('volcano.js','onHeatClickVolcano',[],'hybrid.heatOn');
await capture('volcano.js','onHeatClickVolcano',[],'hybrid.heatOff',{isVolcanoOn:true});
await capture('volcano.js','onAirClickVolcano',[],'hybrid.pumpOn');
await capture('volcano.js','onAirClickVolcano',[],'hybrid.pumpOff',{isPumpOnVolcano:true});
const result={description:'Byte vectors executed from public manufacturer UI functions with mocked GATT; not hardware captures.',
  retrieved:'2026-10-19',sources:Object.entries(source).map(([file,text])=>({file,url:'https://app.storz-bickel.com/js/'+file,sha256:crypto.createHash('sha256').update(text).digest('hex')})),vectors:out};
fs.mkdirSync('test/fixtures',{recursive:true});
fs.writeFileSync('test/fixtures/vendor_vectors.json',JSON.stringify(result,null,2)+'\n');
console.log(out.length+' manufacturer command vectors generated');
