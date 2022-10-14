// deno-fmt-ignore-file
// deno-lint-ignore-file
// This code was bundled using `deno bundle` and it's not recommended to edit it manually

const GetArgs = ()=>{
    return Deno.args;
};
const __default = {
    GetArgs
};
const filters = [
    'AppLoader',
    "DataBinder",
    'makeSureDir',
    "TagParser",
    "ManifestLoader",
    "TagData",
    "FETCH",
    'SYSTEM.ROUTER', 
];
const isFilted = (...vars)=>{
    let res = filters.filter((filter)=>{
        return typeof vars[0][0] === 'string' && vars[0][0].includes(filter);
    });
    return res.length != 0;
};
const __default1 = {
    info: (...vars)=>{
        if (isFilted(vars)) return;
        console.info(new Date(), ...vars);
    },
    error: (...vars)=>{
        if (isFilted(vars)) return;
        console.error(new Date(), ...vars);
    },
    log: (...vars)=>{
        if (isFilted(vars)) return;
        console.log(new Date(), ...vars);
    },
    dev: (...vars)=>{
        console.log(new Date(), ...vars);
    }
};
const isWindows = ()=>{
    return Deno.build.os === "windows";
};
const __default2 = {
    isWindows
};
const homePath = ()=>{
    if (__default2.isWindows()) {
        return (Deno.env.get('HOMEDRIVE') || 'C:') + Deno.env.get('HOMEPATH');
    } else {
        return Deno.env.get('HOME');
    }
};
class Dir {
    constructor(){}
    static get Spelator() {
        if (__default2.isWindows()) {
            return '\\';
        } else {
            return '/';
        }
    }
}
const getDirPath = (filePath)=>{
    if (filePath === '') return filePath;
    return filePath.substring(0, filePath.lastIndexOf(Dir.Spelator));
};
const __default3 = {
    homePath,
    getDirPath,
    Dir
};
const decoder = new TextDecoder('utf-8');
const encoder = new TextEncoder();
const readFileSync = (filePath)=>{
    return decoder.decode(Deno.readFileSync(filePath));
};
const writeFileSync = (filePath, content)=>{
    return Deno.writeFileSync(filePath, encoder.encode(content));
};
const mkdirSync = (path, option)=>{
    return Deno.mkdirSync(path, option);
};
const readDirSync = (filePath)=>{
    let res = [];
    for (const item of Deno.readDirSync(filePath)){
        const dirItem = {
            path: filePath + __default3.Dir.Spelator + item.name,
            ...item
        };
        res.push(dirItem);
    }
    return res;
};
const walkDirSync = (filePath)=>{
    let res = [];
    for (const item of readDirSync(filePath)){
        if (item.isDirectory) {
            res = res.concat(walkDirSync(item.path));
        } else if (item.isFile || item.isSymlibk) {
            res.push(item);
        }
    }
    return res;
};
const statSync = (filePath)=>{
    try {
        const fileid = Deno.openSync(filePath, {
            read: true
        });
        return {
            isExist: true,
            ...Deno.fstatSync(fileid.rid)
        };
    } catch (err) {
        return {
            isExist: false
        };
    }
};
const isEmptyFile = (filePath)=>{
    const s = statSync(filePath);
    if (!s.isExist) {
        return true;
    }
    if (s.isFile) {
        return readFileSync(filePath).trim() === "";
    }
    return true;
};
const unlinkFile = (filePath)=>{
    return Deno.removeSync(filePath);
};
const __default4 = {
    readFileSync,
    writeFileSync,
    mkdirSync,
    readDirSync,
    walkDirSync,
    statSync,
    isEmptyFile,
    unlinkFile
};
const STORAGE_PATH = __default3.homePath() + '/.denkui/storage.json';
let set = async (o)=>{
    let key = o.key;
    let value = o.value;
    __default4.mkdirSync(__default3.homePath() + '/.denkui', {
        recursive: true
    });
    let json = getJson(o);
    json[key] = value;
    let content = JSON.stringify(json);
    __default4.writeFileSync(STORAGE_PATH, content);
};
let getJson = (o)=>{
    o.key;
    let content = '{}';
    try {
        content = __default4.readFileSync(STORAGE_PATH);
    } catch (e) {
        __default1.info('SYSTEM.STORAGE set', 'new sotrage init');
    }
    let json = JSON.parse(content);
    return json;
};
let get = (o)=>{
    let key = o.key;
    let json = getJson(o);
    return new Promise((reslove, rejcet)=>{
        let res = {
            data: json[key]
        };
        reslove(res);
    });
};
const __default5 = {
    set,
    get
};
function deferred() {
    let methods;
    const promise = new Promise((resolve, reject)=>{
        methods = {
            resolve,
            reject
        };
    });
    return Object.assign(promise, methods);
}
class MuxAsyncIterator {
    iteratorCount = 0;
    yields = [];
    throws = [];
    signal = deferred();
    add(iterator) {
        ++this.iteratorCount;
        this.callIteratorNext(iterator);
    }
    async callIteratorNext(iterator) {
        try {
            const { value , done  } = await iterator.next();
            if (done) {
                --this.iteratorCount;
            } else {
                this.yields.push({
                    iterator,
                    value
                });
            }
        } catch (e) {
            this.throws.push(e);
        }
        this.signal.resolve();
    }
    async *iterate() {
        while(this.iteratorCount > 0){
            await this.signal;
            for(let i = 0; i < this.yields.length; i++){
                const { iterator , value  } = this.yields[i];
                yield value;
                this.callIteratorNext(iterator);
            }
            if (this.throws.length) {
                for (const e of this.throws){
                    throw e;
                }
                this.throws.length = 0;
            }
            this.yields.length = 0;
            this.signal = deferred();
        }
    }
    [Symbol.asyncIterator]() {
        return this.iterate();
    }
}
globalThis.Deno?.noColor ?? true;
new RegExp([
    "[\\u001B\\u009B][[\\]()#;?]*(?:(?:(?:[a-zA-Z\\d]*(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]*)*)?\\u0007)",
    "(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-ntqry=><~]))", 
].join("|"), "g");
var DiffType;
(function(DiffType) {
    DiffType["removed"] = "removed";
    DiffType["common"] = "common";
    DiffType["added"] = "added";
})(DiffType || (DiffType = {}));
class DenoStdInternalError extends Error {
    constructor(message){
        super(message);
        this.name = "DenoStdInternalError";
    }
}
function assert(expr, msg = "") {
    if (!expr) {
        throw new DenoStdInternalError(msg);
    }
}
async function writeAll(w, arr) {
    let nwritten = 0;
    while(nwritten < arr.length){
        nwritten += await w.write(arr.subarray(nwritten));
    }
}
TextDecoder;
TextEncoder;
function validateIntegerRange(value, name, min = -2147483648, max = 2147483647) {
    if (!Number.isInteger(value)) {
        throw new Error(`${name} must be 'an integer' but was ${value}`);
    }
    if (value < min || value > max) {
        throw new Error(`${name} must be >= ${min} && <= ${max}. Value was ${value}`);
    }
}
function createIterResult(value, done) {
    return {
        value,
        done
    };
}
let defaultMaxListeners = 10;
class EventEmitter {
    static captureRejectionSymbol = Symbol.for("nodejs.rejection");
    static errorMonitor = Symbol("events.errorMonitor");
    static get defaultMaxListeners() {
        return defaultMaxListeners;
    }
    static set defaultMaxListeners(value) {
        defaultMaxListeners = value;
    }
    maxListeners;
    _events;
    constructor(){
        this._events = new Map();
    }
    _addListener(eventName, listener, prepend) {
        this.emit("newListener", eventName, listener);
        if (this._events.has(eventName)) {
            const listeners = this._events.get(eventName);
            if (prepend) {
                listeners.unshift(listener);
            } else {
                listeners.push(listener);
            }
        } else {
            this._events.set(eventName, [
                listener
            ]);
        }
        const max = this.getMaxListeners();
        if (max > 0 && this.listenerCount(eventName) > max) {
            const warning = new Error(`Possible EventEmitter memory leak detected.
         ${this.listenerCount(eventName)} ${eventName.toString()} listeners.
         Use emitter.setMaxListeners() to increase limit`);
            warning.name = "MaxListenersExceededWarning";
            console.warn(warning);
        }
        return this;
    }
    addListener(eventName, listener) {
        return this._addListener(eventName, listener, false);
    }
    emit(eventName, ...args) {
        if (this._events.has(eventName)) {
            if (eventName === "error" && this._events.get(EventEmitter.errorMonitor)) {
                this.emit(EventEmitter.errorMonitor, ...args);
            }
            const listeners = this._events.get(eventName).slice();
            for (const listener of listeners){
                try {
                    listener.apply(this, args);
                } catch (err) {
                    this.emit("error", err);
                }
            }
            return true;
        } else if (eventName === "error") {
            if (this._events.get(EventEmitter.errorMonitor)) {
                this.emit(EventEmitter.errorMonitor, ...args);
            }
            const errMsg = args.length > 0 ? args[0] : Error("Unhandled error.");
            throw errMsg;
        }
        return false;
    }
    eventNames() {
        return Array.from(this._events.keys());
    }
    getMaxListeners() {
        return this.maxListeners || EventEmitter.defaultMaxListeners;
    }
    listenerCount(eventName) {
        if (this._events.has(eventName)) {
            return this._events.get(eventName).length;
        } else {
            return 0;
        }
    }
    static listenerCount(emitter, eventName) {
        return emitter.listenerCount(eventName);
    }
    _listeners(target, eventName, unwrap) {
        if (!target._events.has(eventName)) {
            return [];
        }
        const eventListeners = target._events.get(eventName);
        return unwrap ? this.unwrapListeners(eventListeners) : eventListeners.slice(0);
    }
    unwrapListeners(arr) {
        const unwrappedListeners = new Array(arr.length);
        for(let i = 0; i < arr.length; i++){
            unwrappedListeners[i] = arr[i]["listener"] || arr[i];
        }
        return unwrappedListeners;
    }
    listeners(eventName) {
        return this._listeners(this, eventName, true);
    }
    rawListeners(eventName) {
        return this._listeners(this, eventName, false);
    }
    off(eventName, listener) {
        return this.removeListener(eventName, listener);
    }
    on(eventName, listener) {
        return this._addListener(eventName, listener, false);
    }
    once(eventName, listener) {
        const wrapped = this.onceWrap(eventName, listener);
        this.on(eventName, wrapped);
        return this;
    }
    onceWrap(eventName, listener) {
        const wrapper = function(...args) {
            this.context.removeListener(this.eventName, this.rawListener);
            this.listener.apply(this.context, args);
        };
        const wrapperContext = {
            eventName: eventName,
            listener: listener,
            rawListener: wrapper,
            context: this
        };
        const wrapped = wrapper.bind(wrapperContext);
        wrapperContext.rawListener = wrapped;
        wrapped.listener = listener;
        return wrapped;
    }
    prependListener(eventName, listener) {
        return this._addListener(eventName, listener, true);
    }
    prependOnceListener(eventName, listener) {
        const wrapped = this.onceWrap(eventName, listener);
        this.prependListener(eventName, wrapped);
        return this;
    }
    removeAllListeners(eventName) {
        if (this._events === undefined) {
            return this;
        }
        if (eventName) {
            if (this._events.has(eventName)) {
                const listeners = this._events.get(eventName).slice();
                this._events.delete(eventName);
                for (const listener of listeners){
                    this.emit("removeListener", eventName, listener);
                }
            }
        } else {
            const eventList = this.eventNames();
            eventList.map((value)=>{
                this.removeAllListeners(value);
            });
        }
        return this;
    }
    removeListener(eventName, listener) {
        if (this._events.has(eventName)) {
            const arr = this._events.get(eventName);
            assert(arr);
            let listenerIndex = -1;
            for(let i = arr.length - 1; i >= 0; i--){
                if (arr[i] == listener || arr[i] && arr[i]["listener"] == listener) {
                    listenerIndex = i;
                    break;
                }
            }
            if (listenerIndex >= 0) {
                arr.splice(listenerIndex, 1);
                this.emit("removeListener", eventName, listener);
                if (arr.length === 0) {
                    this._events.delete(eventName);
                }
            }
        }
        return this;
    }
    setMaxListeners(n) {
        if (n !== Infinity) {
            if (n === 0) {
                n = Infinity;
            } else {
                validateIntegerRange(n, "maxListeners", 0);
            }
        }
        this.maxListeners = n;
        return this;
    }
    static once(emitter, name) {
        return new Promise((resolve, reject)=>{
            if (emitter instanceof EventTarget) {
                emitter.addEventListener(name, (...args)=>{
                    resolve(args);
                }, {
                    once: true,
                    passive: false,
                    capture: false
                });
                return;
            } else if (emitter instanceof EventEmitter) {
                const eventListener = (...args)=>{
                    if (errorListener !== undefined) {
                        emitter.removeListener("error", errorListener);
                    }
                    resolve(args);
                };
                let errorListener;
                if (name !== "error") {
                    errorListener = (err)=>{
                        emitter.removeListener(name, eventListener);
                        reject(err);
                    };
                    emitter.once("error", errorListener);
                }
                emitter.once(name, eventListener);
                return;
            }
        });
    }
    static on(emitter, event) {
        const unconsumedEventValues = [];
        const unconsumedPromises = [];
        let error = null;
        let finished = false;
        const iterator = {
            next () {
                const value = unconsumedEventValues.shift();
                if (value) {
                    return Promise.resolve(createIterResult(value, false));
                }
                if (error) {
                    const p = Promise.reject(error);
                    error = null;
                    return p;
                }
                if (finished) {
                    return Promise.resolve(createIterResult(undefined, true));
                }
                return new Promise(function(resolve, reject) {
                    unconsumedPromises.push({
                        resolve,
                        reject
                    });
                });
            },
            return () {
                emitter.removeListener(event, eventHandler);
                emitter.removeListener("error", errorHandler);
                finished = true;
                for (const promise of unconsumedPromises){
                    promise.resolve(createIterResult(undefined, true));
                }
                return Promise.resolve(createIterResult(undefined, true));
            },
            throw (err) {
                error = err;
                emitter.removeListener(event, eventHandler);
                emitter.removeListener("error", errorHandler);
            },
            [Symbol.asyncIterator] () {
                return this;
            }
        };
        emitter.on(event, eventHandler);
        emitter.on("error", errorHandler);
        return iterator;
        function eventHandler(...args) {
            const promise = unconsumedPromises.shift();
            if (promise) {
                promise.resolve(createIterResult(args, false));
            } else {
                unconsumedEventValues.push(args);
            }
        }
        function errorHandler(err) {
            finished = true;
            const toError = unconsumedPromises.shift();
            if (toError) {
                toError.reject(err);
            } else {
                error = err;
            }
            iterator.return();
        }
    }
}
EventEmitter.captureRejectionSymbol;
EventEmitter.errorMonitor;
EventEmitter.listenerCount;
EventEmitter.on;
EventEmitter.once;
Object.assign(EventEmitter, {
    EventEmitter
});
function concat(...buf) {
    let length = 0;
    for (const b of buf){
        length += b.length;
    }
    const output = new Uint8Array(length);
    let index = 0;
    for (const b1 of buf){
        output.set(b1, index);
        index += b1.length;
    }
    return output;
}
function copy(src, dst, off = 0) {
    off = Math.max(0, Math.min(off, dst.byteLength));
    const dstBytesAvailable = dst.byteLength - off;
    if (src.byteLength > dstBytesAvailable) {
        src = src.subarray(0, dstBytesAvailable);
    }
    dst.set(src, off);
    return src.byteLength;
}
const DEFAULT_BUF_SIZE = 4096;
const MIN_BUF_SIZE = 16;
const CR = "\r".charCodeAt(0);
const LF = "\n".charCodeAt(0);
class BufferFullError extends Error {
    name;
    constructor(partial){
        super("Buffer full");
        this.partial = partial;
        this.name = "BufferFullError";
    }
    partial;
}
class PartialReadError extends Error {
    name = "PartialReadError";
    partial;
    constructor(){
        super("Encountered UnexpectedEof, data only partially read");
    }
}
class BufReader {
    buf;
    rd;
    r = 0;
    w = 0;
    eof = false;
    static create(r, size = 4096) {
        return r instanceof BufReader ? r : new BufReader(r, size);
    }
    constructor(rd, size = 4096){
        if (size < 16) {
            size = MIN_BUF_SIZE;
        }
        this._reset(new Uint8Array(size), rd);
    }
    size() {
        return this.buf.byteLength;
    }
    buffered() {
        return this.w - this.r;
    }
    async _fill() {
        if (this.r > 0) {
            this.buf.copyWithin(0, this.r, this.w);
            this.w -= this.r;
            this.r = 0;
        }
        if (this.w >= this.buf.byteLength) {
            throw Error("bufio: tried to fill full buffer");
        }
        for(let i = 100; i > 0; i--){
            const rr = await this.rd.read(this.buf.subarray(this.w));
            if (rr === null) {
                this.eof = true;
                return;
            }
            assert(rr >= 0, "negative read");
            this.w += rr;
            if (rr > 0) {
                return;
            }
        }
        throw new Error(`No progress after ${100} read() calls`);
    }
    reset(r) {
        this._reset(this.buf, r);
    }
    _reset(buf, rd) {
        this.buf = buf;
        this.rd = rd;
        this.eof = false;
    }
    async read(p) {
        let rr = p.byteLength;
        if (p.byteLength === 0) return rr;
        if (this.r === this.w) {
            if (p.byteLength >= this.buf.byteLength) {
                const rr1 = await this.rd.read(p);
                const nread = rr1 ?? 0;
                assert(nread >= 0, "negative read");
                return rr1;
            }
            this.r = 0;
            this.w = 0;
            rr = await this.rd.read(this.buf);
            if (rr === 0 || rr === null) return rr;
            assert(rr >= 0, "negative read");
            this.w += rr;
        }
        const copied = copy(this.buf.subarray(this.r, this.w), p, 0);
        this.r += copied;
        return copied;
    }
    async readFull(p) {
        let bytesRead = 0;
        while(bytesRead < p.length){
            try {
                const rr = await this.read(p.subarray(bytesRead));
                if (rr === null) {
                    if (bytesRead === 0) {
                        return null;
                    } else {
                        throw new PartialReadError();
                    }
                }
                bytesRead += rr;
            } catch (err) {
                err.partial = p.subarray(0, bytesRead);
                throw err;
            }
        }
        return p;
    }
    async readByte() {
        while(this.r === this.w){
            if (this.eof) return null;
            await this._fill();
        }
        const c = this.buf[this.r];
        this.r++;
        return c;
    }
    async readString(delim) {
        if (delim.length !== 1) {
            throw new Error("Delimiter should be a single character");
        }
        const buffer = await this.readSlice(delim.charCodeAt(0));
        if (buffer === null) return null;
        return new TextDecoder().decode(buffer);
    }
    async readLine() {
        let line;
        try {
            line = await this.readSlice(LF);
        } catch (err) {
            let { partial  } = err;
            assert(partial instanceof Uint8Array, "bufio: caught error from `readSlice()` without `partial` property");
            if (!(err instanceof BufferFullError)) {
                throw err;
            }
            if (!this.eof && partial.byteLength > 0 && partial[partial.byteLength - 1] === CR) {
                assert(this.r > 0, "bufio: tried to rewind past start of buffer");
                this.r--;
                partial = partial.subarray(0, partial.byteLength - 1);
            }
            return {
                line: partial,
                more: !this.eof
            };
        }
        if (line === null) {
            return null;
        }
        if (line.byteLength === 0) {
            return {
                line,
                more: false
            };
        }
        if (line[line.byteLength - 1] == LF) {
            let drop = 1;
            if (line.byteLength > 1 && line[line.byteLength - 2] === CR) {
                drop = 2;
            }
            line = line.subarray(0, line.byteLength - drop);
        }
        return {
            line,
            more: false
        };
    }
    async readSlice(delim) {
        let s = 0;
        let slice;
        while(true){
            let i = this.buf.subarray(this.r + s, this.w).indexOf(delim);
            if (i >= 0) {
                i += s;
                slice = this.buf.subarray(this.r, this.r + i + 1);
                this.r += i + 1;
                break;
            }
            if (this.eof) {
                if (this.r === this.w) {
                    return null;
                }
                slice = this.buf.subarray(this.r, this.w);
                this.r = this.w;
                break;
            }
            if (this.buffered() >= this.buf.byteLength) {
                this.r = this.w;
                const oldbuf = this.buf;
                const newbuf = this.buf.slice(0);
                this.buf = newbuf;
                throw new BufferFullError(oldbuf);
            }
            s = this.w - this.r;
            try {
                await this._fill();
            } catch (err) {
                err.partial = slice;
                throw err;
            }
        }
        return slice;
    }
    async peek(n) {
        if (n < 0) {
            throw Error("negative count");
        }
        let avail = this.w - this.r;
        while(avail < n && avail < this.buf.byteLength && !this.eof){
            try {
                await this._fill();
            } catch (err) {
                err.partial = this.buf.subarray(this.r, this.w);
                throw err;
            }
            avail = this.w - this.r;
        }
        if (avail === 0 && this.eof) {
            return null;
        } else if (avail < n && this.eof) {
            return this.buf.subarray(this.r, this.r + avail);
        } else if (avail < n) {
            throw new BufferFullError(this.buf.subarray(this.r, this.w));
        }
        return this.buf.subarray(this.r, this.r + n);
    }
}
class AbstractBufBase {
    buf;
    usedBufferBytes = 0;
    err = null;
    size() {
        return this.buf.byteLength;
    }
    available() {
        return this.buf.byteLength - this.usedBufferBytes;
    }
    buffered() {
        return this.usedBufferBytes;
    }
}
class BufWriter extends AbstractBufBase {
    static create(writer, size = 4096) {
        return writer instanceof BufWriter ? writer : new BufWriter(writer, size);
    }
    constructor(writer, size = 4096){
        super();
        this.writer = writer;
        if (size <= 0) {
            size = DEFAULT_BUF_SIZE;
        }
        this.buf = new Uint8Array(size);
    }
    reset(w) {
        this.err = null;
        this.usedBufferBytes = 0;
        this.writer = w;
    }
    async flush() {
        if (this.err !== null) throw this.err;
        if (this.usedBufferBytes === 0) return;
        try {
            await writeAll(this.writer, this.buf.subarray(0, this.usedBufferBytes));
        } catch (e) {
            this.err = e;
            throw e;
        }
        this.buf = new Uint8Array(this.buf.length);
        this.usedBufferBytes = 0;
    }
    async write(data) {
        if (this.err !== null) throw this.err;
        if (data.length === 0) return 0;
        let totalBytesWritten = 0;
        let numBytesWritten = 0;
        while(data.byteLength > this.available()){
            if (this.buffered() === 0) {
                try {
                    numBytesWritten = await this.writer.write(data);
                } catch (e) {
                    this.err = e;
                    throw e;
                }
            } else {
                numBytesWritten = copy(data, this.buf, this.usedBufferBytes);
                this.usedBufferBytes += numBytesWritten;
                await this.flush();
            }
            totalBytesWritten += numBytesWritten;
            data = data.subarray(numBytesWritten);
        }
        numBytesWritten = copy(data, this.buf, this.usedBufferBytes);
        this.usedBufferBytes += numBytesWritten;
        totalBytesWritten += numBytesWritten;
        return totalBytesWritten;
    }
    writer;
}
const decoder1 = new TextDecoder();
const invalidHeaderCharRegex = /[^\t\x20-\x7e\x80-\xff]/g;
function str(buf) {
    if (buf == null) {
        return "";
    } else {
        return decoder1.decode(buf);
    }
}
function charCode(s) {
    return s.charCodeAt(0);
}
class TextProtoReader {
    constructor(r){
        this.r = r;
    }
    async readLine() {
        const s = await this.readLineSlice();
        if (s === null) return null;
        return str(s);
    }
    async readMIMEHeader() {
        const m = new Headers();
        let line;
        let buf = await this.r.peek(1);
        if (buf === null) {
            return null;
        } else if (buf[0] == charCode(" ") || buf[0] == charCode("\t")) {
            line = await this.readLineSlice();
        }
        buf = await this.r.peek(1);
        if (buf === null) {
            throw new Deno.errors.UnexpectedEof();
        } else if (buf[0] == charCode(" ") || buf[0] == charCode("\t")) {
            throw new Deno.errors.InvalidData(`malformed MIME header initial line: ${str(line)}`);
        }
        while(true){
            const kv = await this.readLineSlice();
            if (kv === null) throw new Deno.errors.UnexpectedEof();
            if (kv.byteLength === 0) return m;
            let i = kv.indexOf(charCode(":"));
            if (i < 0) {
                throw new Deno.errors.InvalidData(`malformed MIME header line: ${str(kv)}`);
            }
            const key = str(kv.subarray(0, i));
            if (key == "") {
                continue;
            }
            i++;
            while(i < kv.byteLength && (kv[i] == charCode(" ") || kv[i] == charCode("\t"))){
                i++;
            }
            const value = str(kv.subarray(i)).replace(invalidHeaderCharRegex, encodeURI);
            try {
                m.append(key, value);
            } catch  {}
        }
    }
    async readLineSlice() {
        let line;
        while(true){
            const r = await this.r.readLine();
            if (r === null) return null;
            const { line: l , more  } = r;
            if (!line && !more) {
                if (this.skipSpace(l) === 0) {
                    return new Uint8Array(0);
                }
                return l;
            }
            line = line ? concat(line, l) : l;
            if (!more) {
                break;
            }
        }
        return line;
    }
    skipSpace(l) {
        let n = 0;
        for(let i = 0; i < l.length; i++){
            if (l[i] === charCode(" ") || l[i] === charCode("\t")) {
                continue;
            }
            n++;
        }
        return n;
    }
    r;
}
var Status;
(function(Status) {
    Status[Status["Continue"] = 100] = "Continue";
    Status[Status["SwitchingProtocols"] = 101] = "SwitchingProtocols";
    Status[Status["Processing"] = 102] = "Processing";
    Status[Status["EarlyHints"] = 103] = "EarlyHints";
    Status[Status["OK"] = 200] = "OK";
    Status[Status["Created"] = 201] = "Created";
    Status[Status["Accepted"] = 202] = "Accepted";
    Status[Status["NonAuthoritativeInfo"] = 203] = "NonAuthoritativeInfo";
    Status[Status["NoContent"] = 204] = "NoContent";
    Status[Status["ResetContent"] = 205] = "ResetContent";
    Status[Status["PartialContent"] = 206] = "PartialContent";
    Status[Status["MultiStatus"] = 207] = "MultiStatus";
    Status[Status["AlreadyReported"] = 208] = "AlreadyReported";
    Status[Status["IMUsed"] = 226] = "IMUsed";
    Status[Status["MultipleChoices"] = 300] = "MultipleChoices";
    Status[Status["MovedPermanently"] = 301] = "MovedPermanently";
    Status[Status["Found"] = 302] = "Found";
    Status[Status["SeeOther"] = 303] = "SeeOther";
    Status[Status["NotModified"] = 304] = "NotModified";
    Status[Status["UseProxy"] = 305] = "UseProxy";
    Status[Status["TemporaryRedirect"] = 307] = "TemporaryRedirect";
    Status[Status["PermanentRedirect"] = 308] = "PermanentRedirect";
    Status[Status["BadRequest"] = 400] = "BadRequest";
    Status[Status["Unauthorized"] = 401] = "Unauthorized";
    Status[Status["PaymentRequired"] = 402] = "PaymentRequired";
    Status[Status["Forbidden"] = 403] = "Forbidden";
    Status[Status["NotFound"] = 404] = "NotFound";
    Status[Status["MethodNotAllowed"] = 405] = "MethodNotAllowed";
    Status[Status["NotAcceptable"] = 406] = "NotAcceptable";
    Status[Status["ProxyAuthRequired"] = 407] = "ProxyAuthRequired";
    Status[Status["RequestTimeout"] = 408] = "RequestTimeout";
    Status[Status["Conflict"] = 409] = "Conflict";
    Status[Status["Gone"] = 410] = "Gone";
    Status[Status["LengthRequired"] = 411] = "LengthRequired";
    Status[Status["PreconditionFailed"] = 412] = "PreconditionFailed";
    Status[Status["RequestEntityTooLarge"] = 413] = "RequestEntityTooLarge";
    Status[Status["RequestURITooLong"] = 414] = "RequestURITooLong";
    Status[Status["UnsupportedMediaType"] = 415] = "UnsupportedMediaType";
    Status[Status["RequestedRangeNotSatisfiable"] = 416] = "RequestedRangeNotSatisfiable";
    Status[Status["ExpectationFailed"] = 417] = "ExpectationFailed";
    Status[Status["Teapot"] = 418] = "Teapot";
    Status[Status["MisdirectedRequest"] = 421] = "MisdirectedRequest";
    Status[Status["UnprocessableEntity"] = 422] = "UnprocessableEntity";
    Status[Status["Locked"] = 423] = "Locked";
    Status[Status["FailedDependency"] = 424] = "FailedDependency";
    Status[Status["TooEarly"] = 425] = "TooEarly";
    Status[Status["UpgradeRequired"] = 426] = "UpgradeRequired";
    Status[Status["PreconditionRequired"] = 428] = "PreconditionRequired";
    Status[Status["TooManyRequests"] = 429] = "TooManyRequests";
    Status[Status["RequestHeaderFieldsTooLarge"] = 431] = "RequestHeaderFieldsTooLarge";
    Status[Status["UnavailableForLegalReasons"] = 451] = "UnavailableForLegalReasons";
    Status[Status["InternalServerError"] = 500] = "InternalServerError";
    Status[Status["NotImplemented"] = 501] = "NotImplemented";
    Status[Status["BadGateway"] = 502] = "BadGateway";
    Status[Status["ServiceUnavailable"] = 503] = "ServiceUnavailable";
    Status[Status["GatewayTimeout"] = 504] = "GatewayTimeout";
    Status[Status["HTTPVersionNotSupported"] = 505] = "HTTPVersionNotSupported";
    Status[Status["VariantAlsoNegotiates"] = 506] = "VariantAlsoNegotiates";
    Status[Status["InsufficientStorage"] = 507] = "InsufficientStorage";
    Status[Status["LoopDetected"] = 508] = "LoopDetected";
    Status[Status["NotExtended"] = 510] = "NotExtended";
    Status[Status["NetworkAuthenticationRequired"] = 511] = "NetworkAuthenticationRequired";
})(Status || (Status = {}));
const STATUS_TEXT = new Map([
    [
        Status.Continue,
        "Continue"
    ],
    [
        Status.SwitchingProtocols,
        "Switching Protocols"
    ],
    [
        Status.Processing,
        "Processing"
    ],
    [
        Status.EarlyHints,
        "Early Hints"
    ],
    [
        Status.OK,
        "OK"
    ],
    [
        Status.Created,
        "Created"
    ],
    [
        Status.Accepted,
        "Accepted"
    ],
    [
        Status.NonAuthoritativeInfo,
        "Non-Authoritative Information"
    ],
    [
        Status.NoContent,
        "No Content"
    ],
    [
        Status.ResetContent,
        "Reset Content"
    ],
    [
        Status.PartialContent,
        "Partial Content"
    ],
    [
        Status.MultiStatus,
        "Multi-Status"
    ],
    [
        Status.AlreadyReported,
        "Already Reported"
    ],
    [
        Status.IMUsed,
        "IM Used"
    ],
    [
        Status.MultipleChoices,
        "Multiple Choices"
    ],
    [
        Status.MovedPermanently,
        "Moved Permanently"
    ],
    [
        Status.Found,
        "Found"
    ],
    [
        Status.SeeOther,
        "See Other"
    ],
    [
        Status.NotModified,
        "Not Modified"
    ],
    [
        Status.UseProxy,
        "Use Proxy"
    ],
    [
        Status.TemporaryRedirect,
        "Temporary Redirect"
    ],
    [
        Status.PermanentRedirect,
        "Permanent Redirect"
    ],
    [
        Status.BadRequest,
        "Bad Request"
    ],
    [
        Status.Unauthorized,
        "Unauthorized"
    ],
    [
        Status.PaymentRequired,
        "Payment Required"
    ],
    [
        Status.Forbidden,
        "Forbidden"
    ],
    [
        Status.NotFound,
        "Not Found"
    ],
    [
        Status.MethodNotAllowed,
        "Method Not Allowed"
    ],
    [
        Status.NotAcceptable,
        "Not Acceptable"
    ],
    [
        Status.ProxyAuthRequired,
        "Proxy Authentication Required"
    ],
    [
        Status.RequestTimeout,
        "Request Timeout"
    ],
    [
        Status.Conflict,
        "Conflict"
    ],
    [
        Status.Gone,
        "Gone"
    ],
    [
        Status.LengthRequired,
        "Length Required"
    ],
    [
        Status.PreconditionFailed,
        "Precondition Failed"
    ],
    [
        Status.RequestEntityTooLarge,
        "Request Entity Too Large"
    ],
    [
        Status.RequestURITooLong,
        "Request URI Too Long"
    ],
    [
        Status.UnsupportedMediaType,
        "Unsupported Media Type"
    ],
    [
        Status.RequestedRangeNotSatisfiable,
        "Requested Range Not Satisfiable"
    ],
    [
        Status.ExpectationFailed,
        "Expectation Failed"
    ],
    [
        Status.Teapot,
        "I'm a teapot"
    ],
    [
        Status.MisdirectedRequest,
        "Misdirected Request"
    ],
    [
        Status.UnprocessableEntity,
        "Unprocessable Entity"
    ],
    [
        Status.Locked,
        "Locked"
    ],
    [
        Status.FailedDependency,
        "Failed Dependency"
    ],
    [
        Status.TooEarly,
        "Too Early"
    ],
    [
        Status.UpgradeRequired,
        "Upgrade Required"
    ],
    [
        Status.PreconditionRequired,
        "Precondition Required"
    ],
    [
        Status.TooManyRequests,
        "Too Many Requests"
    ],
    [
        Status.RequestHeaderFieldsTooLarge,
        "Request Header Fields Too Large"
    ],
    [
        Status.UnavailableForLegalReasons,
        "Unavailable For Legal Reasons"
    ],
    [
        Status.InternalServerError,
        "Internal Server Error"
    ],
    [
        Status.NotImplemented,
        "Not Implemented"
    ],
    [
        Status.BadGateway,
        "Bad Gateway"
    ],
    [
        Status.ServiceUnavailable,
        "Service Unavailable"
    ],
    [
        Status.GatewayTimeout,
        "Gateway Timeout"
    ],
    [
        Status.HTTPVersionNotSupported,
        "HTTP Version Not Supported"
    ],
    [
        Status.VariantAlsoNegotiates,
        "Variant Also Negotiates"
    ],
    [
        Status.InsufficientStorage,
        "Insufficient Storage"
    ],
    [
        Status.LoopDetected,
        "Loop Detected"
    ],
    [
        Status.NotExtended,
        "Not Extended"
    ],
    [
        Status.NetworkAuthenticationRequired,
        "Network Authentication Required"
    ], 
]);
const encoder1 = new TextEncoder();
function emptyReader() {
    return {
        read (_) {
            return Promise.resolve(null);
        }
    };
}
function bodyReader(contentLength, r) {
    let totalRead = 0;
    let finished = false;
    async function read(buf) {
        if (finished) return null;
        let result;
        const remaining = contentLength - totalRead;
        if (remaining >= buf.byteLength) {
            result = await r.read(buf);
        } else {
            const readBuf = buf.subarray(0, remaining);
            result = await r.read(readBuf);
        }
        if (result !== null) {
            totalRead += result;
        }
        finished = totalRead === contentLength;
        return result;
    }
    return {
        read
    };
}
function chunkedBodyReader(h, r) {
    const tp = new TextProtoReader(r);
    let finished = false;
    const chunks = [];
    async function read(buf) {
        if (finished) return null;
        const [chunk] = chunks;
        if (chunk) {
            const chunkRemaining = chunk.data.byteLength - chunk.offset;
            const readLength = Math.min(chunkRemaining, buf.byteLength);
            for(let i = 0; i < readLength; i++){
                buf[i] = chunk.data[chunk.offset + i];
            }
            chunk.offset += readLength;
            if (chunk.offset === chunk.data.byteLength) {
                chunks.shift();
                if (await tp.readLine() === null) {
                    throw new Deno.errors.UnexpectedEof();
                }
            }
            return readLength;
        }
        const line = await tp.readLine();
        if (line === null) throw new Deno.errors.UnexpectedEof();
        const [chunkSizeString] = line.split(";");
        const chunkSize = parseInt(chunkSizeString, 16);
        if (Number.isNaN(chunkSize) || chunkSize < 0) {
            throw new Deno.errors.InvalidData("Invalid chunk size");
        }
        if (chunkSize > 0) {
            if (chunkSize > buf.byteLength) {
                let eof = await r.readFull(buf);
                if (eof === null) {
                    throw new Deno.errors.UnexpectedEof();
                }
                const restChunk = new Uint8Array(chunkSize - buf.byteLength);
                eof = await r.readFull(restChunk);
                if (eof === null) {
                    throw new Deno.errors.UnexpectedEof();
                } else {
                    chunks.push({
                        offset: 0,
                        data: restChunk
                    });
                }
                return buf.byteLength;
            } else {
                const bufToFill = buf.subarray(0, chunkSize);
                const eof1 = await r.readFull(bufToFill);
                if (eof1 === null) {
                    throw new Deno.errors.UnexpectedEof();
                }
                if (await tp.readLine() === null) {
                    throw new Deno.errors.UnexpectedEof();
                }
                return chunkSize;
            }
        } else {
            assert(chunkSize === 0);
            if (await r.readLine() === null) {
                throw new Deno.errors.UnexpectedEof();
            }
            await readTrailers(h, r);
            finished = true;
            return null;
        }
    }
    return {
        read
    };
}
function isProhibidedForTrailer(key) {
    const s = new Set([
        "transfer-encoding",
        "content-length",
        "trailer"
    ]);
    return s.has(key.toLowerCase());
}
async function readTrailers(headers, r) {
    const trailers = parseTrailer(headers.get("trailer"));
    if (trailers == null) return;
    const trailerNames = [
        ...trailers.keys()
    ];
    const tp = new TextProtoReader(r);
    const result = await tp.readMIMEHeader();
    if (result == null) {
        throw new Deno.errors.InvalidData("Missing trailer header.");
    }
    const undeclared = [
        ...result.keys()
    ].filter((k)=>!trailerNames.includes(k));
    if (undeclared.length > 0) {
        throw new Deno.errors.InvalidData(`Undeclared trailers: ${Deno.inspect(undeclared)}.`);
    }
    for (const [k, v] of result){
        headers.append(k, v);
    }
    const missingTrailers = trailerNames.filter((k)=>!result.has(k));
    if (missingTrailers.length > 0) {
        throw new Deno.errors.InvalidData(`Missing trailers: ${Deno.inspect(missingTrailers)}.`);
    }
    headers.delete("trailer");
}
function parseTrailer(field) {
    if (field == null) {
        return undefined;
    }
    const trailerNames = field.split(",").map((v)=>v.trim().toLowerCase());
    if (trailerNames.length === 0) {
        throw new Deno.errors.InvalidData("Empty trailer header.");
    }
    const prohibited = trailerNames.filter((k)=>isProhibidedForTrailer(k));
    if (prohibited.length > 0) {
        throw new Deno.errors.InvalidData(`Prohibited trailer names: ${Deno.inspect(prohibited)}.`);
    }
    return new Headers(trailerNames.map((key)=>[
            key,
            ""
        ]));
}
async function writeChunkedBody(w, r) {
    for await (const chunk of Deno.iter(r)){
        if (chunk.byteLength <= 0) continue;
        const start = encoder1.encode(`${chunk.byteLength.toString(16)}\r\n`);
        const end = encoder1.encode("\r\n");
        await w.write(start);
        await w.write(chunk);
        await w.write(end);
        await w.flush();
    }
    const endChunk = encoder1.encode("0\r\n\r\n");
    await w.write(endChunk);
}
async function writeTrailers(w, headers, trailers) {
    const trailer = headers.get("trailer");
    if (trailer === null) {
        throw new TypeError("Missing trailer header.");
    }
    const transferEncoding = headers.get("transfer-encoding");
    if (transferEncoding === null || !transferEncoding.match(/^chunked/)) {
        throw new TypeError(`Trailers are only allowed for "transfer-encoding: chunked", got "transfer-encoding: ${transferEncoding}".`);
    }
    const writer = BufWriter.create(w);
    const trailerNames = trailer.split(",").map((s)=>s.trim().toLowerCase());
    const prohibitedTrailers = trailerNames.filter((k)=>isProhibidedForTrailer(k));
    if (prohibitedTrailers.length > 0) {
        throw new TypeError(`Prohibited trailer names: ${Deno.inspect(prohibitedTrailers)}.`);
    }
    const undeclared = [
        ...trailers.keys()
    ].filter((k)=>!trailerNames.includes(k));
    if (undeclared.length > 0) {
        throw new TypeError(`Undeclared trailers: ${Deno.inspect(undeclared)}.`);
    }
    for (const [key, value] of trailers){
        await writer.write(encoder1.encode(`${key}: ${value}\r\n`));
    }
    await writer.write(encoder1.encode("\r\n"));
    await writer.flush();
}
async function writeResponse(w, r) {
    const statusCode = r.status || 200;
    const statusText = STATUS_TEXT.get(statusCode);
    const writer = BufWriter.create(w);
    if (!statusText) {
        throw new Deno.errors.InvalidData("Bad status code");
    }
    if (!r.body) {
        r.body = new Uint8Array();
    }
    if (typeof r.body === "string") {
        r.body = encoder1.encode(r.body);
    }
    let out = `HTTP/${1}.${1} ${statusCode} ${statusText}\r\n`;
    const headers = r.headers ?? new Headers();
    if (r.body && !headers.get("content-length")) {
        if (r.body instanceof Uint8Array) {
            out += `content-length: ${r.body.byteLength}\r\n`;
        } else if (!headers.get("transfer-encoding")) {
            out += "transfer-encoding: chunked\r\n";
        }
    }
    for (const [key, value] of headers){
        out += `${key}: ${value}\r\n`;
    }
    out += `\r\n`;
    const header = encoder1.encode(out);
    const n = await writer.write(header);
    assert(n === header.byteLength);
    if (r.body instanceof Uint8Array) {
        const n1 = await writer.write(r.body);
        assert(n1 === r.body.byteLength);
    } else if (headers.has("content-length")) {
        const contentLength = headers.get("content-length");
        assert(contentLength != null);
        const bodyLength = parseInt(contentLength);
        const n2 = await Deno.copy(r.body, writer);
        assert(n2 === bodyLength);
    } else {
        await writeChunkedBody(writer, r.body);
    }
    if (r.trailers) {
        const t = await r.trailers();
        await writeTrailers(writer, headers, t);
    }
    await writer.flush();
}
class ServerRequest {
    url;
    method;
    proto;
    protoMinor;
    protoMajor;
    headers;
    conn;
    r;
    w;
    #done = deferred();
    #contentLength = undefined;
    #body = undefined;
    #finalized = false;
    get done() {
        return this.#done.then((e)=>e);
    }
    get contentLength() {
        if (this.#contentLength === undefined) {
            const cl = this.headers.get("content-length");
            if (cl) {
                this.#contentLength = parseInt(cl);
                if (Number.isNaN(this.#contentLength)) {
                    this.#contentLength = null;
                }
            } else {
                this.#contentLength = null;
            }
        }
        return this.#contentLength;
    }
    get body() {
        if (!this.#body) {
            if (this.contentLength != null) {
                this.#body = bodyReader(this.contentLength, this.r);
            } else {
                const transferEncoding = this.headers.get("transfer-encoding");
                if (transferEncoding != null) {
                    const parts = transferEncoding.split(",").map((e)=>e.trim().toLowerCase());
                    assert(parts.includes("chunked"), 'transfer-encoding must include "chunked" if content-length is not set');
                    this.#body = chunkedBodyReader(this.headers, this.r);
                } else {
                    this.#body = emptyReader();
                }
            }
        }
        return this.#body;
    }
    async respond(r) {
        let err;
        try {
            await writeResponse(this.w, r);
        } catch (e) {
            try {
                this.conn.close();
            } catch  {}
            err = e;
        }
        this.#done.resolve(err);
        if (err) {
            throw err;
        }
    }
    async finalize() {
        if (this.#finalized) return;
        const body = this.body;
        const buf = new Uint8Array(1024);
        while(await body.read(buf) !== null){}
        this.#finalized = true;
    }
}
function parseHTTPVersion(vers) {
    switch(vers){
        case "HTTP/1.1":
            return [
                1,
                1
            ];
        case "HTTP/1.0":
            return [
                1,
                0
            ];
        default:
            {
                if (!vers.startsWith("HTTP/")) {
                    break;
                }
                const dot = vers.indexOf(".");
                if (dot < 0) {
                    break;
                }
                const majorStr = vers.substring(vers.indexOf("/") + 1, dot);
                const major = Number(majorStr);
                if (!Number.isInteger(major) || major < 0 || major > 1000000) {
                    break;
                }
                const minorStr = vers.substring(dot + 1);
                const minor = Number(minorStr);
                if (!Number.isInteger(minor) || minor < 0 || minor > 1000000) {
                    break;
                }
                return [
                    major,
                    minor
                ];
            }
    }
    throw new Error(`malformed HTTP version ${vers}`);
}
async function readRequest(conn, bufr) {
    const tp = new TextProtoReader(bufr);
    const firstLine = await tp.readLine();
    if (firstLine === null) return null;
    const headers = await tp.readMIMEHeader();
    if (headers === null) throw new Deno.errors.UnexpectedEof();
    const req = new ServerRequest();
    req.conn = conn;
    req.r = bufr;
    [req.method, req.url, req.proto] = firstLine.split(" ", 3);
    [req.protoMajor, req.protoMinor] = parseHTTPVersion(req.proto);
    req.headers = headers;
    fixLength(req);
    return req;
}
class Server {
    #closing;
    #connections;
    constructor(listener){
        this.listener = listener;
        this.#closing = false;
        this.#connections = [];
    }
    close() {
        this.#closing = true;
        this.listener.close();
        for (const conn of this.#connections){
            try {
                conn.close();
            } catch (e) {
                if (!(e instanceof Deno.errors.BadResource)) {
                    throw e;
                }
            }
        }
    }
    async *iterateHttpRequests(conn) {
        const reader = new BufReader(conn);
        const writer = new BufWriter(conn);
        while(!this.#closing){
            let request;
            try {
                request = await readRequest(conn, reader);
            } catch (error) {
                if (error instanceof Deno.errors.InvalidData || error instanceof Deno.errors.UnexpectedEof) {
                    try {
                        await writeResponse(writer, {
                            status: 400,
                            body: new TextEncoder().encode(`${error.message}\r\n\r\n`)
                        });
                    } catch  {}
                }
                break;
            }
            if (request === null) {
                break;
            }
            request.w = writer;
            yield request;
            const responseError = await request.done;
            if (responseError) {
                this.untrackConnection(request.conn);
                return;
            }
            try {
                await request.finalize();
            } catch  {
                break;
            }
        }
        this.untrackConnection(conn);
        try {
            conn.close();
        } catch  {}
    }
    trackConnection(conn) {
        this.#connections.push(conn);
    }
    untrackConnection(conn) {
        const index = this.#connections.indexOf(conn);
        if (index !== -1) {
            this.#connections.splice(index, 1);
        }
    }
    async *acceptConnAndIterateHttpRequests(mux) {
        if (this.#closing) return;
        let conn;
        try {
            conn = await this.listener.accept();
        } catch (error) {
            if (error instanceof Deno.errors.BadResource || error instanceof Deno.errors.InvalidData || error instanceof Deno.errors.UnexpectedEof || error instanceof Deno.errors.ConnectionReset) {
                return mux.add(this.acceptConnAndIterateHttpRequests(mux));
            }
            throw error;
        }
        this.trackConnection(conn);
        mux.add(this.acceptConnAndIterateHttpRequests(mux));
        yield* this.iterateHttpRequests(conn);
    }
    [Symbol.asyncIterator]() {
        const mux = new MuxAsyncIterator();
        mux.add(this.acceptConnAndIterateHttpRequests(mux));
        return mux.iterate();
    }
    listener;
}
function _parseAddrFromStr(addr) {
    let url;
    try {
        const host = addr.startsWith(":") ? `0.0.0.0${addr}` : addr;
        url = new URL(`http://${host}`);
    } catch  {
        throw new TypeError("Invalid address.");
    }
    if (url.username || url.password || url.pathname != "/" || url.search || url.hash) {
        throw new TypeError("Invalid address.");
    }
    return {
        hostname: url.hostname,
        port: url.port === "" ? 80 : Number(url.port)
    };
}
function serve(addr) {
    if (typeof addr === "string") {
        addr = _parseAddrFromStr(addr);
    }
    const listener = Deno.listen(addr);
    return new Server(listener);
}
function fixLength(req) {
    const contentLength = req.headers.get("Content-Length");
    if (contentLength) {
        const arrClen = contentLength.split(",");
        if (arrClen.length > 1) {
            const distinct = [
                ...new Set(arrClen.map((e)=>e.trim()))
            ];
            if (distinct.length > 1) {
                throw Error("cannot contain multiple Content-Length headers");
            } else {
                req.headers.set("Content-Length", distinct[0]);
            }
        }
        const c = req.headers.get("Content-Length");
        if (req.method === "HEAD" && c && c !== "0") {
            throw Error("http: method cannot contain a Content-Length");
        }
        if (c && req.headers.has("transfer-encoding")) {
            throw new Error("http: Transfer-Encoding and Content-Length cannot be send together");
        }
    }
}
function hasOwnProperty(obj, v) {
    if (obj == null) {
        return false;
    }
    return Object.prototype.hasOwnProperty.call(obj, v);
}
async function readShort(buf) {
    const high = await buf.readByte();
    if (high === null) return null;
    const low = await buf.readByte();
    if (low === null) throw new Deno.errors.UnexpectedEof();
    return high << 8 | low;
}
async function readInt(buf) {
    const high = await readShort(buf);
    if (high === null) return null;
    const low = await readShort(buf);
    if (low === null) throw new Deno.errors.UnexpectedEof();
    return high << 16 | low;
}
const MAX_SAFE_INTEGER = BigInt(Number.MAX_SAFE_INTEGER);
async function readLong(buf) {
    const high = await readInt(buf);
    if (high === null) return null;
    const low = await readInt(buf);
    if (low === null) throw new Deno.errors.UnexpectedEof();
    const big = BigInt(high) << 32n | BigInt(low);
    if (big > MAX_SAFE_INTEGER) {
        throw new RangeError("Long value too big to be represented as a JavaScript number.");
    }
    return Number(big);
}
function sliceLongToBytes(d, dest = new Array(8)) {
    let big = BigInt(d);
    for(let i = 0; i < 8; i++){
        dest[7 - i] = Number(big & 0xffn);
        big >>= 8n;
    }
    return dest;
}
const HEX_CHARS = "0123456789abcdef".split("");
const EXTRA = [
    -2147483648,
    8388608,
    32768,
    128
];
const SHIFT = [
    24,
    16,
    8,
    0
];
const blocks = [];
class Sha1 {
    #blocks;
    #block;
    #start;
    #bytes;
    #hBytes;
    #finalized;
    #hashed;
    #h0 = 0x67452301;
    #h1 = 0xefcdab89;
    #h2 = 0x98badcfe;
    #h3 = 0x10325476;
    #h4 = 0xc3d2e1f0;
    #lastByteIndex = 0;
    constructor(sharedMemory = false){
        this.init(sharedMemory);
    }
    init(sharedMemory) {
        if (sharedMemory) {
            blocks[0] = blocks[16] = blocks[1] = blocks[2] = blocks[3] = blocks[4] = blocks[5] = blocks[6] = blocks[7] = blocks[8] = blocks[9] = blocks[10] = blocks[11] = blocks[12] = blocks[13] = blocks[14] = blocks[15] = 0;
            this.#blocks = blocks;
        } else {
            this.#blocks = [
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0
            ];
        }
        this.#h0 = 0x67452301;
        this.#h1 = 0xefcdab89;
        this.#h2 = 0x98badcfe;
        this.#h3 = 0x10325476;
        this.#h4 = 0xc3d2e1f0;
        this.#block = this.#start = this.#bytes = this.#hBytes = 0;
        this.#finalized = this.#hashed = false;
    }
    update(message) {
        if (this.#finalized) {
            return this;
        }
        let msg;
        if (message instanceof ArrayBuffer) {
            msg = new Uint8Array(message);
        } else {
            msg = message;
        }
        let index = 0;
        const length = msg.length;
        const blocks = this.#blocks;
        while(index < length){
            let i;
            if (this.#hashed) {
                this.#hashed = false;
                blocks[0] = this.#block;
                blocks[16] = blocks[1] = blocks[2] = blocks[3] = blocks[4] = blocks[5] = blocks[6] = blocks[7] = blocks[8] = blocks[9] = blocks[10] = blocks[11] = blocks[12] = blocks[13] = blocks[14] = blocks[15] = 0;
            }
            if (typeof msg !== "string") {
                for(i = this.#start; index < length && i < 64; ++index){
                    blocks[i >> 2] |= msg[index] << SHIFT[i++ & 3];
                }
            } else {
                for(i = this.#start; index < length && i < 64; ++index){
                    let code = msg.charCodeAt(index);
                    if (code < 0x80) {
                        blocks[i >> 2] |= code << SHIFT[i++ & 3];
                    } else if (code < 0x800) {
                        blocks[i >> 2] |= (0xc0 | code >> 6) << SHIFT[i++ & 3];
                        blocks[i >> 2] |= (0x80 | code & 0x3f) << SHIFT[i++ & 3];
                    } else if (code < 0xd800 || code >= 0xe000) {
                        blocks[i >> 2] |= (0xe0 | code >> 12) << SHIFT[i++ & 3];
                        blocks[i >> 2] |= (0x80 | code >> 6 & 0x3f) << SHIFT[i++ & 3];
                        blocks[i >> 2] |= (0x80 | code & 0x3f) << SHIFT[i++ & 3];
                    } else {
                        code = 0x10000 + ((code & 0x3ff) << 10 | msg.charCodeAt(++index) & 0x3ff);
                        blocks[i >> 2] |= (0xf0 | code >> 18) << SHIFT[i++ & 3];
                        blocks[i >> 2] |= (0x80 | code >> 12 & 0x3f) << SHIFT[i++ & 3];
                        blocks[i >> 2] |= (0x80 | code >> 6 & 0x3f) << SHIFT[i++ & 3];
                        blocks[i >> 2] |= (0x80 | code & 0x3f) << SHIFT[i++ & 3];
                    }
                }
            }
            this.#lastByteIndex = i;
            this.#bytes += i - this.#start;
            if (i >= 64) {
                this.#block = blocks[16];
                this.#start = i - 64;
                this.hash();
                this.#hashed = true;
            } else {
                this.#start = i;
            }
        }
        if (this.#bytes > 4294967295) {
            this.#hBytes += this.#bytes / 4294967296 >>> 0;
            this.#bytes = this.#bytes >>> 0;
        }
        return this;
    }
    finalize() {
        if (this.#finalized) {
            return;
        }
        this.#finalized = true;
        const blocks = this.#blocks;
        const i = this.#lastByteIndex;
        blocks[16] = this.#block;
        blocks[i >> 2] |= EXTRA[i & 3];
        this.#block = blocks[16];
        if (i >= 56) {
            if (!this.#hashed) {
                this.hash();
            }
            blocks[0] = this.#block;
            blocks[16] = blocks[1] = blocks[2] = blocks[3] = blocks[4] = blocks[5] = blocks[6] = blocks[7] = blocks[8] = blocks[9] = blocks[10] = blocks[11] = blocks[12] = blocks[13] = blocks[14] = blocks[15] = 0;
        }
        blocks[14] = this.#hBytes << 3 | this.#bytes >>> 29;
        blocks[15] = this.#bytes << 3;
        this.hash();
    }
    hash() {
        let a = this.#h0;
        let b = this.#h1;
        let c = this.#h2;
        let d = this.#h3;
        let e = this.#h4;
        let f;
        let j;
        let t;
        const blocks = this.#blocks;
        for(j = 16; j < 80; ++j){
            t = blocks[j - 3] ^ blocks[j - 8] ^ blocks[j - 14] ^ blocks[j - 16];
            blocks[j] = t << 1 | t >>> 31;
        }
        for(j = 0; j < 20; j += 5){
            f = b & c | ~b & d;
            t = a << 5 | a >>> 27;
            e = t + f + e + 1518500249 + blocks[j] >>> 0;
            b = b << 30 | b >>> 2;
            f = a & b | ~a & c;
            t = e << 5 | e >>> 27;
            d = t + f + d + 1518500249 + blocks[j + 1] >>> 0;
            a = a << 30 | a >>> 2;
            f = e & a | ~e & b;
            t = d << 5 | d >>> 27;
            c = t + f + c + 1518500249 + blocks[j + 2] >>> 0;
            e = e << 30 | e >>> 2;
            f = d & e | ~d & a;
            t = c << 5 | c >>> 27;
            b = t + f + b + 1518500249 + blocks[j + 3] >>> 0;
            d = d << 30 | d >>> 2;
            f = c & d | ~c & e;
            t = b << 5 | b >>> 27;
            a = t + f + a + 1518500249 + blocks[j + 4] >>> 0;
            c = c << 30 | c >>> 2;
        }
        for(; j < 40; j += 5){
            f = b ^ c ^ d;
            t = a << 5 | a >>> 27;
            e = t + f + e + 1859775393 + blocks[j] >>> 0;
            b = b << 30 | b >>> 2;
            f = a ^ b ^ c;
            t = e << 5 | e >>> 27;
            d = t + f + d + 1859775393 + blocks[j + 1] >>> 0;
            a = a << 30 | a >>> 2;
            f = e ^ a ^ b;
            t = d << 5 | d >>> 27;
            c = t + f + c + 1859775393 + blocks[j + 2] >>> 0;
            e = e << 30 | e >>> 2;
            f = d ^ e ^ a;
            t = c << 5 | c >>> 27;
            b = t + f + b + 1859775393 + blocks[j + 3] >>> 0;
            d = d << 30 | d >>> 2;
            f = c ^ d ^ e;
            t = b << 5 | b >>> 27;
            a = t + f + a + 1859775393 + blocks[j + 4] >>> 0;
            c = c << 30 | c >>> 2;
        }
        for(; j < 60; j += 5){
            f = b & c | b & d | c & d;
            t = a << 5 | a >>> 27;
            e = t + f + e - 1894007588 + blocks[j] >>> 0;
            b = b << 30 | b >>> 2;
            f = a & b | a & c | b & c;
            t = e << 5 | e >>> 27;
            d = t + f + d - 1894007588 + blocks[j + 1] >>> 0;
            a = a << 30 | a >>> 2;
            f = e & a | e & b | a & b;
            t = d << 5 | d >>> 27;
            c = t + f + c - 1894007588 + blocks[j + 2] >>> 0;
            e = e << 30 | e >>> 2;
            f = d & e | d & a | e & a;
            t = c << 5 | c >>> 27;
            b = t + f + b - 1894007588 + blocks[j + 3] >>> 0;
            d = d << 30 | d >>> 2;
            f = c & d | c & e | d & e;
            t = b << 5 | b >>> 27;
            a = t + f + a - 1894007588 + blocks[j + 4] >>> 0;
            c = c << 30 | c >>> 2;
        }
        for(; j < 80; j += 5){
            f = b ^ c ^ d;
            t = a << 5 | a >>> 27;
            e = t + f + e - 899497514 + blocks[j] >>> 0;
            b = b << 30 | b >>> 2;
            f = a ^ b ^ c;
            t = e << 5 | e >>> 27;
            d = t + f + d - 899497514 + blocks[j + 1] >>> 0;
            a = a << 30 | a >>> 2;
            f = e ^ a ^ b;
            t = d << 5 | d >>> 27;
            c = t + f + c - 899497514 + blocks[j + 2] >>> 0;
            e = e << 30 | e >>> 2;
            f = d ^ e ^ a;
            t = c << 5 | c >>> 27;
            b = t + f + b - 899497514 + blocks[j + 3] >>> 0;
            d = d << 30 | d >>> 2;
            f = c ^ d ^ e;
            t = b << 5 | b >>> 27;
            a = t + f + a - 899497514 + blocks[j + 4] >>> 0;
            c = c << 30 | c >>> 2;
        }
        this.#h0 = this.#h0 + a >>> 0;
        this.#h1 = this.#h1 + b >>> 0;
        this.#h2 = this.#h2 + c >>> 0;
        this.#h3 = this.#h3 + d >>> 0;
        this.#h4 = this.#h4 + e >>> 0;
    }
    hex() {
        this.finalize();
        const h0 = this.#h0;
        const h1 = this.#h1;
        const h2 = this.#h2;
        const h3 = this.#h3;
        const h4 = this.#h4;
        return HEX_CHARS[h0 >> 28 & 0x0f] + HEX_CHARS[h0 >> 24 & 0x0f] + HEX_CHARS[h0 >> 20 & 0x0f] + HEX_CHARS[h0 >> 16 & 0x0f] + HEX_CHARS[h0 >> 12 & 0x0f] + HEX_CHARS[h0 >> 8 & 0x0f] + HEX_CHARS[h0 >> 4 & 0x0f] + HEX_CHARS[h0 & 0x0f] + HEX_CHARS[h1 >> 28 & 0x0f] + HEX_CHARS[h1 >> 24 & 0x0f] + HEX_CHARS[h1 >> 20 & 0x0f] + HEX_CHARS[h1 >> 16 & 0x0f] + HEX_CHARS[h1 >> 12 & 0x0f] + HEX_CHARS[h1 >> 8 & 0x0f] + HEX_CHARS[h1 >> 4 & 0x0f] + HEX_CHARS[h1 & 0x0f] + HEX_CHARS[h2 >> 28 & 0x0f] + HEX_CHARS[h2 >> 24 & 0x0f] + HEX_CHARS[h2 >> 20 & 0x0f] + HEX_CHARS[h2 >> 16 & 0x0f] + HEX_CHARS[h2 >> 12 & 0x0f] + HEX_CHARS[h2 >> 8 & 0x0f] + HEX_CHARS[h2 >> 4 & 0x0f] + HEX_CHARS[h2 & 0x0f] + HEX_CHARS[h3 >> 28 & 0x0f] + HEX_CHARS[h3 >> 24 & 0x0f] + HEX_CHARS[h3 >> 20 & 0x0f] + HEX_CHARS[h3 >> 16 & 0x0f] + HEX_CHARS[h3 >> 12 & 0x0f] + HEX_CHARS[h3 >> 8 & 0x0f] + HEX_CHARS[h3 >> 4 & 0x0f] + HEX_CHARS[h3 & 0x0f] + HEX_CHARS[h4 >> 28 & 0x0f] + HEX_CHARS[h4 >> 24 & 0x0f] + HEX_CHARS[h4 >> 20 & 0x0f] + HEX_CHARS[h4 >> 16 & 0x0f] + HEX_CHARS[h4 >> 12 & 0x0f] + HEX_CHARS[h4 >> 8 & 0x0f] + HEX_CHARS[h4 >> 4 & 0x0f] + HEX_CHARS[h4 & 0x0f];
    }
    toString() {
        return this.hex();
    }
    digest() {
        this.finalize();
        const h0 = this.#h0;
        const h1 = this.#h1;
        const h2 = this.#h2;
        const h3 = this.#h3;
        const h4 = this.#h4;
        return [
            h0 >> 24 & 0xff,
            h0 >> 16 & 0xff,
            h0 >> 8 & 0xff,
            h0 & 0xff,
            h1 >> 24 & 0xff,
            h1 >> 16 & 0xff,
            h1 >> 8 & 0xff,
            h1 & 0xff,
            h2 >> 24 & 0xff,
            h2 >> 16 & 0xff,
            h2 >> 8 & 0xff,
            h2 & 0xff,
            h3 >> 24 & 0xff,
            h3 >> 16 & 0xff,
            h3 >> 8 & 0xff,
            h3 & 0xff,
            h4 >> 24 & 0xff,
            h4 >> 16 & 0xff,
            h4 >> 8 & 0xff,
            h4 & 0xff, 
        ];
    }
    array() {
        return this.digest();
    }
    arrayBuffer() {
        this.finalize();
        const buffer = new ArrayBuffer(20);
        const dataView = new DataView(buffer);
        dataView.setUint32(0, this.#h0);
        dataView.setUint32(4, this.#h1);
        dataView.setUint32(8, this.#h2);
        dataView.setUint32(12, this.#h3);
        dataView.setUint32(16, this.#h4);
        return buffer;
    }
}
var OpCode;
(function(OpCode) {
    OpCode[OpCode["Continue"] = 0x0] = "Continue";
    OpCode[OpCode["TextFrame"] = 0x1] = "TextFrame";
    OpCode[OpCode["BinaryFrame"] = 0x2] = "BinaryFrame";
    OpCode[OpCode["Close"] = 0x8] = "Close";
    OpCode[OpCode["Ping"] = 0x9] = "Ping";
    OpCode[OpCode["Pong"] = 0xa] = "Pong";
})(OpCode || (OpCode = {}));
function isWebSocketCloseEvent(a) {
    return hasOwnProperty(a, "code");
}
function isWebSocketPingEvent(a) {
    return Array.isArray(a) && a[0] === "ping" && a[1] instanceof Uint8Array;
}
function isWebSocketPongEvent(a) {
    return Array.isArray(a) && a[0] === "pong" && a[1] instanceof Uint8Array;
}
function unmask(payload, mask) {
    if (mask) {
        for(let i = 0, len = payload.length; i < len; i++){
            payload[i] ^= mask[i & 3];
        }
    }
}
async function writeFrame(frame, writer) {
    const payloadLength = frame.payload.byteLength;
    let header;
    const hasMask = frame.mask ? 0x80 : 0;
    if (frame.mask && frame.mask.byteLength !== 4) {
        throw new Error("invalid mask. mask must be 4 bytes: length=" + frame.mask.byteLength);
    }
    if (payloadLength < 126) {
        header = new Uint8Array([
            0x80 | frame.opcode,
            hasMask | payloadLength
        ]);
    } else if (payloadLength < 0xffff) {
        header = new Uint8Array([
            0x80 | frame.opcode,
            hasMask | 0b01111110,
            payloadLength >>> 8,
            payloadLength & 0x00ff, 
        ]);
    } else {
        header = new Uint8Array([
            0x80 | frame.opcode,
            hasMask | 0b01111111,
            ...sliceLongToBytes(payloadLength), 
        ]);
    }
    if (frame.mask) {
        header = concat(header, frame.mask);
    }
    unmask(frame.payload, frame.mask);
    header = concat(header, frame.payload);
    const w = BufWriter.create(writer);
    await w.write(header);
    await w.flush();
}
async function readFrame(buf) {
    let b = await buf.readByte();
    assert(b !== null);
    let isLastFrame = false;
    switch(b >>> 4){
        case 0b1000:
            isLastFrame = true;
            break;
        case 0b0000:
            isLastFrame = false;
            break;
        default:
            throw new Error("invalid signature");
    }
    const opcode = b & 0x0f;
    b = await buf.readByte();
    assert(b !== null);
    const hasMask = b >>> 7;
    let payloadLength = b & 0b01111111;
    if (payloadLength === 126) {
        const l = await readShort(buf);
        assert(l !== null);
        payloadLength = l;
    } else if (payloadLength === 127) {
        const l1 = await readLong(buf);
        assert(l1 !== null);
        payloadLength = Number(l1);
    }
    let mask;
    if (hasMask) {
        mask = new Uint8Array(4);
        assert(await buf.readFull(mask) !== null);
    }
    const payload = new Uint8Array(payloadLength);
    assert(await buf.readFull(payload) !== null);
    return {
        isLastFrame,
        opcode,
        mask,
        payload
    };
}
class WebSocketImpl {
    conn;
    mask;
    bufReader;
    bufWriter;
    sendQueue = [];
    constructor({ conn , bufReader , bufWriter , mask  }){
        this.conn = conn;
        this.mask = mask;
        this.bufReader = bufReader || new BufReader(conn);
        this.bufWriter = bufWriter || new BufWriter(conn);
    }
    async *[Symbol.asyncIterator]() {
        const decoder = new TextDecoder();
        let frames = [];
        let payloadsLength = 0;
        while(!this._isClosed){
            let frame;
            try {
                frame = await readFrame(this.bufReader);
            } catch  {
                this.ensureSocketClosed();
                break;
            }
            unmask(frame.payload, frame.mask);
            switch(frame.opcode){
                case OpCode.TextFrame:
                case OpCode.BinaryFrame:
                case OpCode.Continue:
                    frames.push(frame);
                    payloadsLength += frame.payload.length;
                    if (frame.isLastFrame) {
                        const concat = new Uint8Array(payloadsLength);
                        let offs = 0;
                        for (const frame1 of frames){
                            concat.set(frame1.payload, offs);
                            offs += frame1.payload.length;
                        }
                        if (frames[0].opcode === OpCode.TextFrame) {
                            yield decoder.decode(concat);
                        } else {
                            yield concat;
                        }
                        frames = [];
                        payloadsLength = 0;
                    }
                    break;
                case OpCode.Close:
                    {
                        const code = frame.payload[0] << 8 | frame.payload[1];
                        const reason = decoder.decode(frame.payload.subarray(2, frame.payload.length));
                        await this.close(code, reason);
                        yield {
                            code,
                            reason
                        };
                        return;
                    }
                case OpCode.Ping:
                    await this.enqueue({
                        opcode: OpCode.Pong,
                        payload: frame.payload,
                        isLastFrame: true
                    });
                    yield [
                        "ping",
                        frame.payload
                    ];
                    break;
                case OpCode.Pong:
                    yield [
                        "pong",
                        frame.payload
                    ];
                    break;
                default:
            }
        }
    }
    dequeue() {
        const [entry] = this.sendQueue;
        if (!entry) return;
        if (this._isClosed) return;
        const { d , frame  } = entry;
        writeFrame(frame, this.bufWriter).then(()=>d.resolve()).catch((e)=>d.reject(e)).finally(()=>{
            this.sendQueue.shift();
            this.dequeue();
        });
    }
    enqueue(frame) {
        if (this._isClosed) {
            throw new Deno.errors.ConnectionReset("Socket has already been closed");
        }
        const d = deferred();
        this.sendQueue.push({
            d,
            frame
        });
        if (this.sendQueue.length === 1) {
            this.dequeue();
        }
        return d;
    }
    send(data) {
        const opcode = typeof data === "string" ? OpCode.TextFrame : OpCode.BinaryFrame;
        const payload = typeof data === "string" ? new TextEncoder().encode(data) : data;
        const frame = {
            isLastFrame: true,
            opcode,
            payload,
            mask: this.mask
        };
        return this.enqueue(frame);
    }
    ping(data = "") {
        const payload = typeof data === "string" ? new TextEncoder().encode(data) : data;
        const frame = {
            isLastFrame: true,
            opcode: OpCode.Ping,
            mask: this.mask,
            payload
        };
        return this.enqueue(frame);
    }
    _isClosed = false;
    get isClosed() {
        return this._isClosed;
    }
    async close(code = 1000, reason) {
        try {
            const header = [
                code >>> 8,
                code & 0x00ff
            ];
            let payload;
            if (reason) {
                const reasonBytes = new TextEncoder().encode(reason);
                payload = new Uint8Array(2 + reasonBytes.byteLength);
                payload.set(header);
                payload.set(reasonBytes, 2);
            } else {
                payload = new Uint8Array(header);
            }
            await this.enqueue({
                isLastFrame: true,
                opcode: OpCode.Close,
                mask: this.mask,
                payload
            });
        } catch (e) {
            throw e;
        } finally{
            this.ensureSocketClosed();
        }
    }
    closeForce() {
        this.ensureSocketClosed();
    }
    ensureSocketClosed() {
        if (this.isClosed) return;
        try {
            this.conn.close();
        } catch (e) {
            console.error(e);
        } finally{
            this._isClosed = true;
            const rest = this.sendQueue;
            this.sendQueue = [];
            rest.forEach((e)=>e.d.reject(new Deno.errors.ConnectionReset("Socket has already been closed")));
        }
    }
}
function acceptable(req) {
    const upgrade = req.headers.get("upgrade");
    if (!upgrade || upgrade.toLowerCase() !== "websocket") {
        return false;
    }
    const secKey = req.headers.get("sec-websocket-key");
    return req.headers.has("sec-websocket-key") && typeof secKey === "string" && secKey.length > 0;
}
const kGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
function createSecAccept(nonce) {
    const sha1 = new Sha1();
    sha1.update(nonce + kGUID);
    const bytes = sha1.digest();
    return btoa(String.fromCharCode(...bytes));
}
async function acceptWebSocket(req) {
    const { conn , headers , bufReader , bufWriter  } = req;
    if (acceptable(req)) {
        const sock = new WebSocketImpl({
            conn,
            bufReader,
            bufWriter
        });
        const secKey = headers.get("sec-websocket-key");
        if (typeof secKey !== "string") {
            throw new Error("sec-websocket-key is not provided");
        }
        const secAccept = createSecAccept(secKey);
        const newHeaders = new Headers({
            Upgrade: "websocket",
            Connection: "Upgrade",
            "Sec-WebSocket-Accept": secAccept
        });
        const secProtocol = headers.get("sec-websocket-protocol");
        if (typeof secProtocol === "string") {
            newHeaders.set("Sec-WebSocket-Protocol", secProtocol);
        }
        const secVersion = headers.get("sec-websocket-version");
        if (typeof secVersion === "string") {
            newHeaders.set("Sec-WebSocket-Version", secVersion);
        }
        await writeResponse(bufWriter, {
            status: 101,
            headers: newHeaders
        });
        return sock;
    }
    throw new Error("request is not acceptable");
}
class WebSocketError extends Error {
    constructor(e){
        super(e);
        Object.setPrototypeOf(this, WebSocketError.prototype);
    }
}
var WebSocketState;
(function(WebSocketState) {
    WebSocketState[WebSocketState["CONNECTING"] = 0] = "CONNECTING";
    WebSocketState[WebSocketState["OPEN"] = 1] = "OPEN";
    WebSocketState[WebSocketState["CLOSING"] = 2] = "CLOSING";
    WebSocketState[WebSocketState["CLOSED"] = 3] = "CLOSED";
})(WebSocketState || (WebSocketState = {}));
class WebSocketServer extends EventEmitter {
    clients;
    server;
    constructor(port = 8080, realIpHeader = null){
        super();
        this.port = port;
        this.realIpHeader = realIpHeader;
        this.clients = new Set();
        this.server = undefined;
        this.connect();
    }
    async connect() {
        this.server = serve(`:${this.port}`);
        for await (const req of this.server){
            const { conn , r: bufReader , w: bufWriter , headers  } = req;
            try {
                const sock = await acceptWebSocket({
                    conn,
                    bufReader,
                    bufWriter,
                    headers
                });
                if (this.realIpHeader && "hostname" in sock.conn.remoteAddr) {
                    if (!req.headers.has(this.realIpHeader)) {
                        this.emit("error", new Error("specified real ip header does not exist"));
                    } else {
                        sock.conn.remoteAddr.hostname = req.headers.get(this.realIpHeader) || sock.conn.remoteAddr.hostname;
                    }
                }
                const ws = new WebSocketAcceptedClient(sock);
                this.clients.add(ws);
                this.emit("connection", ws, req.url);
            } catch (err) {
                this.emit("error", err);
                await req.respond({
                    status: 400
                });
            }
        }
    }
    async close() {
        this.server?.close();
        this.clients.clear();
    }
    port;
    realIpHeader;
}
class WebSocketAcceptedClient extends EventEmitter {
    state = WebSocketState.CONNECTING;
    webSocket;
    constructor(sock){
        super();
        this.webSocket = sock;
        this.open();
    }
    async open() {
        this.state = WebSocketState.OPEN;
        this.emit("open");
        try {
            for await (const ev of this.webSocket){
                if (typeof ev === "string") {
                    this.emit("message", ev);
                } else if (ev instanceof Uint8Array) {
                    this.emit("message", ev);
                } else if (isWebSocketPingEvent(ev)) {
                    const [, body] = ev;
                    this.emit("ping", body);
                } else if (isWebSocketPongEvent(ev)) {
                    const [, body1] = ev;
                    this.emit("pong", body1);
                } else if (isWebSocketCloseEvent(ev)) {
                    const { code , reason  } = ev;
                    this.state = WebSocketState.CLOSED;
                    this.emit("close", code);
                }
            }
        } catch (err) {
            this.emit("close", err);
            if (!this.webSocket.isClosed) {
                await this.webSocket.close(1000).catch((e)=>{
                    if (this.state === WebSocketState.CLOSING && this.webSocket.isClosed) {
                        this.state = WebSocketState.CLOSED;
                        return;
                    }
                    throw new WebSocketError(e);
                });
            }
        }
    }
    async ping(message) {
        if (this.state === WebSocketState.CONNECTING) {
            throw new WebSocketError("WebSocket is not open: state 0 (CONNECTING)");
        }
        return this.webSocket.ping(message);
    }
    async send(message) {
        try {
            if (this.state === WebSocketState.CONNECTING) {
                throw new WebSocketError("WebSocket is not open: state 0 (CONNECTING)");
            }
            return this.webSocket.send(message);
        } catch (error) {
            this.state = WebSocketState.CLOSED;
            this.emit("close", error.message);
        }
    }
    async close(code = 1000, reason) {
        if (this.state === WebSocketState.CLOSING || this.state === WebSocketState.CLOSED) {
            return;
        }
        this.state = WebSocketState.CLOSING;
        return this.webSocket.close(code, reason);
    }
    async closeForce() {
        if (this.state === WebSocketState.CLOSING || this.state === WebSocketState.CLOSED) {
            return;
        }
        this.state = WebSocketState.CLOSING;
        return this.webSocket.closeForce();
    }
    get isClosed() {
        return this.webSocket.isClosed;
    }
}
class IpcController {
    wss;
    ws = null;
    callbacks = [];
    onConnected = [];
    constructor(port){
        this.wss = new WebSocketServer(port);
        __default1.info("IpcController init at port ", port);
        this.wss.on("connection", (ws)=>{
            this.ws = ws;
            __default1.info('IpcController ws connection success at', new Date());
            this.onConnected.forEach((i)=>i());
            this.ws.on("message", (message)=>{
                __default1.info('IpcController on message', message);
                this.callbacks.forEach((i)=>{
                    i(message);
                });
            });
        });
    }
    send(data) {
        data && this.ws?.send(data);
    }
    addOnConnectCallback(callback) {
        this.onConnected.push(callback);
    }
    addCallback(callback) {
        this.callbacks.push(callback);
    }
}
class AsyncIpcController extends IpcController {
    send(message) {
        super.send(message);
    }
    response(data) {
        data.isResponse = true;
        this.send(JSON.stringify(data));
    }
}
const handleFile = (content, filePath)=>{
    __default1.info(filePath);
    content = content.replace(/\r/g, '');
    let headerInfoReg = /^----*\n(.*\n)*---\n/;
    const header = headerInfoReg.exec(content);
    __default1.info('header', header);
    let headerText = header && header[0].replace(/tag *:/, 'tags:');
    const headerInfo = {};
    headerText?.split('\n').filter((line)=>!line.includes('---')).forEach((line)=>{
        if (line.includes(':')) {
            let values = line.split(':');
            const key = values[0].trim();
            let value = line.split(':')[1].trim();
            if (values.length > 2) {
                values = values.slice(1);
                value = values.join(':').trim();
            }
            if (value != "") {
                headerInfo[key] = value;
                headerInfo.isArrayItem = false;
            } else {
                headerInfo.isArrayItem = true;
                headerInfo.arrItemTag = key;
                headerInfo[key] = [];
            }
        } else if (line.startsWith('-')) {
            if (headerInfo.isArrayItem) {
                headerInfo[headerInfo.arrItemTag].push(line.split('-')[1].trim().toLowerCase());
            }
        }
    });
    __default1.info(headerText);
    if (headerText == null) {}
    delete headerInfo.isArrayItem;
    delete headerInfo.arrItemTag;
    if (!headerInfo.tags || headerInfo.tags && headerInfo.tags.length === 0) {
        if (!headerInfo.tag || headerInfo.tag && headerInfo.tag.length === 0) {
            headerInfo.tags = headerInfo.tag;
        }
        headerInfo.tags = [
            'UnTag'
        ];
    }
    headerInfo.path = filePath;
    __default1.info(headerInfo);
    return headerInfo;
};
const __default6 = {
    handleFile
};
class BlogTextHelper {
    static GenerateEmptyText(title = '${title}', tags = [
        '${tag}'
    ], content = '') {
        const res = `---
title: ${title}
date: ${new Date().toLocaleString()}
tags:
${tags.map((value)=>{
            return `- ${value}
`;
        })}
---
${content}






`;
        return res;
    }
    static GetHeaderInfoFromText(fullContent) {
        fullContent = fullContent.replace(/\r/g, '');
        let headerInfoReg = /^----*\n(.*\n)*---\n/;
        const header = headerInfoReg.exec(fullContent);
        const headerText = header && header[0];
        return headerText;
    }
    static GetContentFromText(fullContent) {
        const headerText = BlogTextHelper.GetHeaderInfoFromText(fullContent);
        return fullContent.replace(headerText, '');
    }
}
let sendToastFunc = console.info;
const __default7 = {
    init: (f)=>{
        sendToastFunc = f;
    },
    error: (o)=>{
        __default1.info("SYSTEM.TOAST ERROR => ", o);
        __default1.info(sendToastFunc);
        sendToastFunc({
            name: 'system.toast',
            data: {
                error: `${o}`
            }
        });
    },
    info: (o)=>{
        __default1.info("SYSTEM.TOAST INFO => ", o);
        __default1.info(sendToastFunc);
        sendToastFunc({
            name: 'system.toast',
            data: {
                msg: `${o}`
            }
        });
    }
};
const getDefaultFileExtByType = (type)=>{
    if (type === 'denkuiblog') {
        return 'md';
    }
    if (type === 'text') {
        return 'denkuitext';
    }
    if (type === 'script') {
        return 'js';
    }
    return 'DENKNONONONONNONONONO';
};
const getFileExtByType = (type, config)=>{
    if (!config || !config.filterFiles) {
        return getDefaultFileExtByType(type);
    }
    const filter = config.filterFiles;
    if (typeof filter == 'object' && filter instanceof Array) {
        for(let x in filter){
            const v = filter[x];
            if (v.type === type) {
                return v.ext;
            }
        }
    }
    return getDefaultFileExtByType(type);
};
const __default8 = {
    getFileExtByType
};
const CHAR = "\t\n\r\u0020-\uD7FF\uE000-\uFFFD\u{10000}-\u{10FFFF}";
const S = " \t\r\n";
const NAME_START_CHAR = ":A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\u{10000}-\u{EFFFF}";
const NAME_CHAR = `-${NAME_START_CHAR}.0-9\u00B7\u0300-\u036F\u203F-\u2040`;
new RegExp(`^[${CHAR}]$`, "u");
new RegExp(`^[${S}]+$`, "u");
new RegExp(`^[${NAME_START_CHAR}]$`, "u");
new RegExp(`^[${NAME_CHAR}]$`, "u");
const NAME_RE = new RegExp(`^[${NAME_START_CHAR}][${NAME_CHAR}]*$`, "u");
new RegExp(`^[${NAME_CHAR}]+$`, "u");
const S_LIST = [
    0x20,
    0xA,
    0xD,
    9
];
function isChar(c) {
    return c >= 0x20 && c <= 0xD7FF || c === 0xA || c === 0xD || c === 9 || c >= 0xE000 && c <= 0xFFFD || c >= 0x10000 && c <= 0x10FFFF;
}
function isS(c) {
    return c === 0x20 || c === 0xA || c === 0xD || c === 9;
}
function isNameStartChar(c) {
    return c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A || c === 0x3A || c === 0x5F || c === 0x200C || c === 0x200D || c >= 0xC0 && c <= 0xD6 || c >= 0xD8 && c <= 0xF6 || c >= 0x00F8 && c <= 0x02FF || c >= 0x0370 && c <= 0x037D || c >= 0x037F && c <= 0x1FFF || c >= 0x2070 && c <= 0x218F || c >= 0x2C00 && c <= 0x2FEF || c >= 0x3001 && c <= 0xD7FF || c >= 0xF900 && c <= 0xFDCF || c >= 0xFDF0 && c <= 0xFFFD || c >= 0x10000 && c <= 0xEFFFF;
}
function isNameChar(c) {
    return isNameStartChar(c) || c >= 0x30 && c <= 0x39 || c === 0x2D || c === 0x2E || c === 0xB7 || c >= 0x0300 && c <= 0x036F || c >= 0x203F && c <= 0x2040;
}
const CHAR1 = "\u0001-\uD7FF\uE000-\uFFFD\u{10000}-\u{10FFFF}";
const RESTRICTED_CHAR = "\u0001-\u0008\u000B\u000C\u000E-\u001F\u007F-\u0084\u0086-\u009F";
const S1 = " \t\r\n";
const NAME_START_CHAR1 = ":A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\u{10000}-\u{EFFFF}";
const NAME_CHAR1 = `-${NAME_START_CHAR1}.0-9\u00B7\u0300-\u036F\u203F-\u2040`;
new RegExp(`^[${CHAR1}]$`, "u");
new RegExp(`^[${RESTRICTED_CHAR}]$`, "u");
new RegExp(`^[${S1}]+$`, "u");
new RegExp(`^[${NAME_START_CHAR1}]$`, "u");
new RegExp(`^[${NAME_CHAR1}]$`, "u");
new RegExp(`^[${NAME_START_CHAR1}][${NAME_CHAR1}]*$`, "u");
new RegExp(`^[${NAME_CHAR1}]+$`, "u");
function isChar1(c) {
    return c >= 0x0001 && c <= 0xD7FF || c >= 0xE000 && c <= 0xFFFD || c >= 0x10000 && c <= 0x10FFFF;
}
const NC_NAME_START_CHAR = "A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\u{10000}-\u{EFFFF}";
const NC_NAME_CHAR = `-${NC_NAME_START_CHAR}.0-9\u00B7\u0300-\u036F\u203F-\u2040`;
new RegExp(`^[${NC_NAME_START_CHAR}]$`, "u");
new RegExp(`^[${NC_NAME_CHAR}]$`, "u");
const NC_NAME_RE = new RegExp(`^[${NC_NAME_START_CHAR}][${NC_NAME_CHAR}]*$`, "u");
function isNCNameStartChar(c) {
    return c >= 0x41 && c <= 0x5A || c === 0x5F || c >= 0x61 && c <= 0x7A || c >= 0xC0 && c <= 0xD6 || c >= 0xD8 && c <= 0xF6 || c >= 0x00F8 && c <= 0x02FF || c >= 0x0370 && c <= 0x037D || c >= 0x037F && c <= 0x1FFF || c >= 0x200C && c <= 0x200D || c >= 0x2070 && c <= 0x218F || c >= 0x2C00 && c <= 0x2FEF || c >= 0x3001 && c <= 0xD7FF || c >= 0xF900 && c <= 0xFDCF || c >= 0xFDF0 && c <= 0xFFFD || c >= 0x10000 && c <= 0xEFFFF;
}
function isNCNameChar(c) {
    return isNCNameStartChar(c) || c === 0x2D || c === 0x2E || c >= 0x30 && c <= 0x39 || c === 0x00B7 || c >= 0x0300 && c <= 0x036F || c >= 0x203F && c <= 0x2040;
}
var isS1 = isS;
var isChar10 = isChar;
var isNameStartChar1 = isNameStartChar;
var isNameChar1 = isNameChar;
var S_LIST1 = S_LIST;
var NAME_RE1 = NAME_RE;
var isChar11 = isChar1;
var isNCNameStartChar1 = isNCNameStartChar;
var isNCNameChar1 = isNCNameChar;
var NC_NAME_RE1 = NC_NAME_RE;
const XML_NAMESPACE = "http://www.w3.org/XML/1998/namespace";
const XMLNS_NAMESPACE = "http://www.w3.org/2000/xmlns/";
const rootNS = {
    __proto__: null,
    xml: XML_NAMESPACE,
    xmlns: XMLNS_NAMESPACE
};
const XML_ENTITIES = {
    __proto__: null,
    amp: "&",
    gt: ">",
    lt: "<",
    quot: "\"",
    apos: "'"
};
const EOC = -1;
const NL_LIKE = -2;
const S_BEGIN = 0;
const S_BEGIN_WHITESPACE = 1;
const S_DOCTYPE = 2;
const S_DOCTYPE_QUOTE = 3;
const S_DTD = 4;
const S_DTD_QUOTED = 5;
const S_DTD_OPEN_WAKA = 6;
const S_DTD_OPEN_WAKA_BANG = 7;
const S_DTD_COMMENT = 8;
const S_DTD_COMMENT_ENDING = 9;
const S_DTD_COMMENT_ENDED = 10;
const S_DTD_PI = 11;
const S_DTD_PI_ENDING = 12;
const S_TEXT = 13;
const S_ENTITY = 14;
const S_OPEN_WAKA = 15;
const S_OPEN_WAKA_BANG = 16;
const S_COMMENT = 17;
const S_COMMENT_ENDING = 18;
const S_COMMENT_ENDED = 19;
const S_CDATA = 20;
const S_CDATA_ENDING = 21;
const S_CDATA_ENDING_2 = 22;
const S_PI_FIRST_CHAR = 23;
const S_PI_REST = 24;
const S_PI_BODY = 25;
const S_PI_ENDING = 26;
const S_XML_DECL_NAME_START = 27;
const S_XML_DECL_NAME = 28;
const S_XML_DECL_EQ = 29;
const S_XML_DECL_VALUE_START = 30;
const S_XML_DECL_VALUE = 31;
const S_XML_DECL_SEPARATOR = 32;
const S_XML_DECL_ENDING = 33;
const S_OPEN_TAG = 34;
const S_OPEN_TAG_SLASH = 35;
const S_ATTRIB = 36;
const S_ATTRIB_NAME = 37;
const S_ATTRIB_NAME_SAW_WHITE = 38;
const S_ATTRIB_VALUE = 39;
const S_ATTRIB_VALUE_QUOTED = 40;
const S_ATTRIB_VALUE_CLOSED = 41;
const S_ATTRIB_VALUE_UNQUOTED = 42;
const S_CLOSE_TAG = 43;
const S_CLOSE_TAG_SAW_WHITE = 44;
const NL = 0xA;
const SPACE = 0x20;
const MINUS = 0x2D;
const EQUAL = 0x3D;
const QUESTION = 0x3F;
const isQuote = (c)=>c === 0x22 || c === 0x27;
const QUOTES = [
    0x22,
    0x27
];
const DOCTYPE_TERMINATOR = [
    ...QUOTES,
    0x5B,
    0x3E
];
const DTD_TERMINATOR = [
    ...QUOTES,
    0x3C,
    0x5D
];
const XML_DECL_NAME_TERMINATOR = [
    0x3D,
    0x3F,
    ...S_LIST1
];
const ATTRIB_VALUE_UNQUOTED_TERMINATOR = [
    ...S_LIST1,
    0x3E,
    0x26,
    0x3C
];
function nsPairCheck(parser, prefix, uri) {
    switch(prefix){
        case "xml":
            if (uri !== XML_NAMESPACE) {
                parser.fail(`xml prefix must be bound to ${XML_NAMESPACE}.`);
            }
            break;
        case "xmlns":
            if (uri !== XMLNS_NAMESPACE) {
                parser.fail(`xmlns prefix must be bound to ${XMLNS_NAMESPACE}.`);
            }
            break;
        default:
    }
    switch(uri){
        case XMLNS_NAMESPACE:
            parser.fail(prefix === "" ? `the default namespace may not be set to ${uri}.` : `may not assign a prefix (even "xmlns") to the URI \
${XMLNS_NAMESPACE}.`);
            break;
        case XML_NAMESPACE:
            switch(prefix){
                case "xml":
                    break;
                case "":
                    parser.fail(`the default namespace may not be set to ${uri}.`);
                    break;
                default:
                    parser.fail("may not assign the xml namespace to another prefix.");
            }
            break;
        default:
    }
}
function nsMappingCheck(parser, mapping) {
    for (const local of Object.keys(mapping)){
        nsPairCheck(parser, local, mapping[local]);
    }
}
const isNCName = (name)=>NC_NAME_RE1.test(name);
const isName = (name)=>NAME_RE1.test(name);
const FORBIDDEN_START = 0;
const FORBIDDEN_BRACKET = 1;
const FORBIDDEN_BRACKET_BRACKET = 2;
const EVENT_NAME_TO_HANDLER_NAME = {
    xmldecl: "xmldeclHandler",
    text: "textHandler",
    processinginstruction: "piHandler",
    doctype: "doctypeHandler",
    comment: "commentHandler",
    opentagstart: "openTagStartHandler",
    attribute: "attributeHandler",
    opentag: "openTagHandler",
    closetag: "closeTagHandler",
    cdata: "cdataHandler",
    error: "errorHandler",
    end: "endHandler",
    ready: "readyHandler"
};
class SaxesParser {
    fragmentOpt;
    xmlnsOpt;
    trackPosition;
    fileName;
    nameStartCheck;
    nameCheck;
    isName;
    ns;
    openWakaBang;
    text;
    name;
    piTarget;
    entity;
    q;
    tags;
    tag;
    topNS;
    chunk;
    chunkPosition;
    i;
    prevI;
    carriedFromPrevious;
    forbiddenState;
    attribList;
    state;
    reportedTextBeforeRoot;
    reportedTextAfterRoot;
    closedRoot;
    sawRoot;
    xmlDeclPossible;
    xmlDeclExpects;
    entityReturnState;
    processAttribs;
    positionAtNewLine;
    doctype;
    getCode;
    isChar;
    pushAttrib;
    _closed;
    currentXMLVersion;
    stateTable;
    xmldeclHandler;
    textHandler;
    piHandler;
    doctypeHandler;
    commentHandler;
    openTagStartHandler;
    openTagHandler;
    closeTagHandler;
    cdataHandler;
    errorHandler;
    endHandler;
    readyHandler;
    attributeHandler;
    get closed() {
        return this._closed;
    }
    opt;
    xmlDecl;
    line;
    column;
    ENTITIES;
    constructor(opt){
        this.opt = opt ?? {};
        this.fragmentOpt = !!this.opt.fragment;
        const xmlnsOpt = this.xmlnsOpt = !!this.opt.xmlns;
        this.trackPosition = this.opt.position !== false;
        this.fileName = this.opt.fileName;
        if (xmlnsOpt) {
            this.nameStartCheck = isNCNameStartChar1;
            this.nameCheck = isNCNameChar1;
            this.isName = isNCName;
            this.processAttribs = this.processAttribsNS;
            this.pushAttrib = this.pushAttribNS;
            this.ns = {
                __proto__: null,
                ...rootNS
            };
            const additional = this.opt.additionalNamespaces;
            if (additional != null) {
                nsMappingCheck(this, additional);
                Object.assign(this.ns, additional);
            }
        } else {
            this.nameStartCheck = isNameStartChar1;
            this.nameCheck = isNameChar1;
            this.isName = isName;
            this.processAttribs = this.processAttribsPlain;
            this.pushAttrib = this.pushAttribPlain;
        }
        this.stateTable = [
            this.sBegin,
            this.sBeginWhitespace,
            this.sDoctype,
            this.sDoctypeQuote,
            this.sDTD,
            this.sDTDQuoted,
            this.sDTDOpenWaka,
            this.sDTDOpenWakaBang,
            this.sDTDComment,
            this.sDTDCommentEnding,
            this.sDTDCommentEnded,
            this.sDTDPI,
            this.sDTDPIEnding,
            this.sText,
            this.sEntity,
            this.sOpenWaka,
            this.sOpenWakaBang,
            this.sComment,
            this.sCommentEnding,
            this.sCommentEnded,
            this.sCData,
            this.sCDataEnding,
            this.sCDataEnding2,
            this.sPIFirstChar,
            this.sPIRest,
            this.sPIBody,
            this.sPIEnding,
            this.sXMLDeclNameStart,
            this.sXMLDeclName,
            this.sXMLDeclEq,
            this.sXMLDeclValueStart,
            this.sXMLDeclValue,
            this.sXMLDeclSeparator,
            this.sXMLDeclEnding,
            this.sOpenTag,
            this.sOpenTagSlash,
            this.sAttrib,
            this.sAttribName,
            this.sAttribNameSawWhite,
            this.sAttribValue,
            this.sAttribValueQuoted,
            this.sAttribValueClosed,
            this.sAttribValueUnquoted,
            this.sCloseTag,
            this.sCloseTagSawWhite
        ];
        this._init();
    }
    _init() {
        this.openWakaBang = "";
        this.text = "";
        this.name = "";
        this.piTarget = "";
        this.entity = "";
        this.q = null;
        this.tags = [];
        this.tag = null;
        this.topNS = null;
        this.chunk = "";
        this.chunkPosition = 0;
        this.i = 0;
        this.prevI = 0;
        this.carriedFromPrevious = undefined;
        this.forbiddenState = FORBIDDEN_START;
        this.attribList = [];
        const { fragmentOpt  } = this;
        this.state = fragmentOpt ? S_TEXT : S_BEGIN;
        this.reportedTextBeforeRoot = this.reportedTextAfterRoot = this.closedRoot = this.sawRoot = fragmentOpt;
        this.xmlDeclPossible = !fragmentOpt;
        this.xmlDeclExpects = [
            "version"
        ];
        this.entityReturnState = undefined;
        let { defaultXMLVersion  } = this.opt;
        if (defaultXMLVersion === undefined) {
            if (this.opt.forceXMLVersion === true) {
                throw new Error("forceXMLVersion set but defaultXMLVersion is not set");
            }
            defaultXMLVersion = "1.0";
        }
        this.setXMLVersion(defaultXMLVersion);
        this.positionAtNewLine = 0;
        this.doctype = false;
        this._closed = false;
        this.xmlDecl = {
            version: undefined,
            encoding: undefined,
            standalone: undefined
        };
        this.line = 1;
        this.column = 0;
        this.ENTITIES = Object.create(XML_ENTITIES);
        this.readyHandler?.();
    }
    get position() {
        return this.chunkPosition + this.i;
    }
    get columnIndex() {
        return this.position - this.positionAtNewLine;
    }
    on(name, handler) {
        this[EVENT_NAME_TO_HANDLER_NAME[name]] = handler;
    }
    off(name) {
        this[EVENT_NAME_TO_HANDLER_NAME[name]] = undefined;
    }
    makeError(message) {
        let msg = this.fileName ?? "";
        if (this.trackPosition) {
            if (msg.length > 0) {
                msg += ":";
            }
            msg += `${this.line}:${this.column}`;
        }
        if (msg.length > 0) {
            msg += ": ";
        }
        return new Error(msg + message);
    }
    fail(message) {
        const err = this.makeError(message);
        const handler = this.errorHandler;
        if (handler === undefined) {
            throw err;
        } else {
            handler(err);
        }
        return this;
    }
    write(chunk) {
        if (this.closed) {
            return this.fail("cannot write after close; assign an onready handler.");
        }
        let end = false;
        if (chunk === null) {
            end = true;
            chunk = "";
        } else if (typeof chunk === "object") {
            chunk = chunk.toString();
        }
        if (this.carriedFromPrevious !== undefined) {
            chunk = `${this.carriedFromPrevious}${chunk}`;
            this.carriedFromPrevious = undefined;
        }
        let limit = chunk.length;
        const lastCode = chunk.charCodeAt(limit - 1);
        if (!end && (lastCode === 0xD || lastCode >= 0xD800 && lastCode <= 0xDBFF)) {
            this.carriedFromPrevious = chunk[limit - 1];
            limit--;
            chunk = chunk.slice(0, limit);
        }
        const { stateTable  } = this;
        this.chunk = chunk;
        this.i = 0;
        while(this.i < limit){
            stateTable[this.state].call(this);
        }
        this.chunkPosition += limit;
        return end ? this.end() : this;
    }
    close() {
        return this.write(null);
    }
    getCode10() {
        const { chunk , i  } = this;
        this.prevI = i;
        this.i = i + 1;
        if (i >= chunk.length) {
            return EOC;
        }
        const code = chunk.charCodeAt(i);
        this.column++;
        if (code < 0xD800) {
            if (code >= 0x20 || code === 9) {
                return code;
            }
            switch(code){
                case 0xA:
                    this.line++;
                    this.column = 0;
                    this.positionAtNewLine = this.position;
                    return 0xA;
                case 0xD:
                    if (chunk.charCodeAt(i + 1) === 0xA) {
                        this.i = i + 2;
                    }
                    this.line++;
                    this.column = 0;
                    this.positionAtNewLine = this.position;
                    return NL_LIKE;
                default:
                    this.fail("disallowed character.");
                    return code;
            }
        }
        if (code > 0xDBFF) {
            if (!(code >= 0xE000 && code <= 0xFFFD)) {
                this.fail("disallowed character.");
            }
            return code;
        }
        const __final = 0x10000 + (code - 0xD800) * 0x400 + (chunk.charCodeAt(i + 1) - 0xDC00);
        this.i = i + 2;
        if (__final > 0x10FFFF) {
            this.fail("disallowed character.");
        }
        return __final;
    }
    getCode11() {
        const { chunk , i  } = this;
        this.prevI = i;
        this.i = i + 1;
        if (i >= chunk.length) {
            return EOC;
        }
        const code = chunk.charCodeAt(i);
        this.column++;
        if (code < 0xD800) {
            if (code > 0x1F && code < 0x7F || code > 0x9F && code !== 0x2028 || code === 9) {
                return code;
            }
            switch(code){
                case 0xA:
                    this.line++;
                    this.column = 0;
                    this.positionAtNewLine = this.position;
                    return 0xA;
                case 0xD:
                    {
                        const next = chunk.charCodeAt(i + 1);
                        if (next === 0xA || next === 0x85) {
                            this.i = i + 2;
                        }
                    }
                case 0x85:
                case 0x2028:
                    this.line++;
                    this.column = 0;
                    this.positionAtNewLine = this.position;
                    return NL_LIKE;
                default:
                    this.fail("disallowed character.");
                    return code;
            }
        }
        if (code > 0xDBFF) {
            if (!(code >= 0xE000 && code <= 0xFFFD)) {
                this.fail("disallowed character.");
            }
            return code;
        }
        const __final = 0x10000 + (code - 0xD800) * 0x400 + (chunk.charCodeAt(i + 1) - 0xDC00);
        this.i = i + 2;
        if (__final > 0x10FFFF) {
            this.fail("disallowed character.");
        }
        return __final;
    }
    getCodeNorm() {
        const c = this.getCode();
        return c === NL_LIKE ? 0xA : c;
    }
    unget() {
        this.i = this.prevI;
        this.column--;
    }
    captureTo(chars) {
        let { i: start  } = this;
        const { chunk  } = this;
        while(true){
            const c = this.getCode();
            const isNLLike = c === NL_LIKE;
            const __final = isNLLike ? 0xA : c;
            if (__final === EOC || chars.includes(__final)) {
                this.text += chunk.slice(start, this.prevI);
                return __final;
            }
            if (isNLLike) {
                this.text += `${chunk.slice(start, this.prevI)}\n`;
                start = this.i;
            }
        }
    }
    captureToChar(__char) {
        let { i: start  } = this;
        const { chunk  } = this;
        while(true){
            let c = this.getCode();
            switch(c){
                case NL_LIKE:
                    this.text += `${chunk.slice(start, this.prevI)}\n`;
                    start = this.i;
                    c = NL;
                    break;
                case EOC:
                    this.text += chunk.slice(start);
                    return false;
                default:
            }
            if (c === __char) {
                this.text += chunk.slice(start, this.prevI);
                return true;
            }
        }
    }
    captureNameChars() {
        const { chunk , i: start  } = this;
        while(true){
            const c = this.getCode();
            if (c === EOC) {
                this.name += chunk.slice(start);
                return EOC;
            }
            if (!isNameChar1(c)) {
                this.name += chunk.slice(start, this.prevI);
                return c === NL_LIKE ? 0xA : c;
            }
        }
    }
    skipSpaces() {
        while(true){
            const c = this.getCodeNorm();
            if (c === EOC || !isS1(c)) {
                return c;
            }
        }
    }
    setXMLVersion(version) {
        this.currentXMLVersion = version;
        if (version === "1.0") {
            this.isChar = isChar10;
            this.getCode = this.getCode10;
        } else {
            this.isChar = isChar11;
            this.getCode = this.getCode11;
        }
    }
    sBegin() {
        if (this.chunk.charCodeAt(0) === 0xFEFF) {
            this.i++;
            this.column++;
        }
        this.state = S_BEGIN_WHITESPACE;
    }
    sBeginWhitespace() {
        const iBefore = this.i;
        const c = this.skipSpaces();
        if (this.prevI !== iBefore) {
            this.xmlDeclPossible = false;
        }
        switch(c){
            case 0x3C:
                this.state = S_OPEN_WAKA;
                if (this.text.length !== 0) {
                    throw new Error("no-empty text at start");
                }
                break;
            case EOC:
                break;
            default:
                this.unget();
                this.state = S_TEXT;
                this.xmlDeclPossible = false;
        }
    }
    sDoctype() {
        const c = this.captureTo(DOCTYPE_TERMINATOR);
        switch(c){
            case 0x3E:
                {
                    this.doctypeHandler?.(this.text);
                    this.text = "";
                    this.state = S_TEXT;
                    this.doctype = true;
                    break;
                }
            case EOC:
                break;
            default:
                this.text += String.fromCodePoint(c);
                if (c === 0x5B) {
                    this.state = S_DTD;
                } else if (isQuote(c)) {
                    this.state = S_DOCTYPE_QUOTE;
                    this.q = c;
                }
        }
    }
    sDoctypeQuote() {
        const q = this.q;
        if (this.captureToChar(q)) {
            this.text += String.fromCodePoint(q);
            this.q = null;
            this.state = S_DOCTYPE;
        }
    }
    sDTD() {
        const c = this.captureTo(DTD_TERMINATOR);
        if (c === EOC) {
            return;
        }
        this.text += String.fromCodePoint(c);
        if (c === 0x5D) {
            this.state = S_DOCTYPE;
        } else if (c === 0x3C) {
            this.state = S_DTD_OPEN_WAKA;
        } else if (isQuote(c)) {
            this.state = S_DTD_QUOTED;
            this.q = c;
        }
    }
    sDTDQuoted() {
        const q = this.q;
        if (this.captureToChar(q)) {
            this.text += String.fromCodePoint(q);
            this.state = S_DTD;
            this.q = null;
        }
    }
    sDTDOpenWaka() {
        const c = this.getCodeNorm();
        this.text += String.fromCodePoint(c);
        switch(c){
            case 0x21:
                this.state = S_DTD_OPEN_WAKA_BANG;
                this.openWakaBang = "";
                break;
            case 0x3F:
                this.state = S_DTD_PI;
                break;
            default:
                this.state = S_DTD;
        }
    }
    sDTDOpenWakaBang() {
        const __char = String.fromCodePoint(this.getCodeNorm());
        const owb = this.openWakaBang += __char;
        this.text += __char;
        if (owb !== "-") {
            this.state = owb === "--" ? S_DTD_COMMENT : S_DTD;
            this.openWakaBang = "";
        }
    }
    sDTDComment() {
        if (this.captureToChar(0x2D)) {
            this.text += "-";
            this.state = S_DTD_COMMENT_ENDING;
        }
    }
    sDTDCommentEnding() {
        const c = this.getCodeNorm();
        this.text += String.fromCodePoint(c);
        this.state = c === MINUS ? S_DTD_COMMENT_ENDED : S_DTD_COMMENT;
    }
    sDTDCommentEnded() {
        const c = this.getCodeNorm();
        this.text += String.fromCodePoint(c);
        if (c === 0x3E) {
            this.state = S_DTD;
        } else {
            this.fail("malformed comment.");
            this.state = S_DTD_COMMENT;
        }
    }
    sDTDPI() {
        if (this.captureToChar(0x3F)) {
            this.text += "?";
            this.state = S_DTD_PI_ENDING;
        }
    }
    sDTDPIEnding() {
        const c = this.getCodeNorm();
        this.text += String.fromCodePoint(c);
        if (c === 0x3E) {
            this.state = S_DTD;
        }
    }
    sText() {
        if (this.tags.length !== 0) {
            this.handleTextInRoot();
        } else {
            this.handleTextOutsideRoot();
        }
    }
    sEntity() {
        let { i: start  } = this;
        const { chunk  } = this;
        loop: while(true){
            switch(this.getCode()){
                case NL_LIKE:
                    this.entity += `${chunk.slice(start, this.prevI)}\n`;
                    start = this.i;
                    break;
                case 0x3B:
                    {
                        const { entityReturnState  } = this;
                        const entity = this.entity + chunk.slice(start, this.prevI);
                        this.state = entityReturnState;
                        let parsed;
                        if (entity === "") {
                            this.fail("empty entity name.");
                            parsed = "&;";
                        } else {
                            parsed = this.parseEntity(entity);
                            this.entity = "";
                        }
                        if (entityReturnState !== 13 || this.textHandler !== undefined) {
                            this.text += parsed;
                        }
                        break loop;
                    }
                case EOC:
                    this.entity += chunk.slice(start);
                    break loop;
                default:
            }
        }
    }
    sOpenWaka() {
        const c = this.getCode();
        if (isNameStartChar1(c)) {
            this.state = S_OPEN_TAG;
            this.unget();
            this.xmlDeclPossible = false;
        } else {
            switch(c){
                case 0x2F:
                    this.state = S_CLOSE_TAG;
                    this.xmlDeclPossible = false;
                    break;
                case 0x21:
                    this.state = S_OPEN_WAKA_BANG;
                    this.openWakaBang = "";
                    this.xmlDeclPossible = false;
                    break;
                case 0x3F:
                    this.state = S_PI_FIRST_CHAR;
                    break;
                default:
                    this.fail("disallowed character in tag name");
                    this.state = S_TEXT;
                    this.xmlDeclPossible = false;
            }
        }
    }
    sOpenWakaBang() {
        this.openWakaBang += String.fromCodePoint(this.getCodeNorm());
        switch(this.openWakaBang){
            case "[CDATA[":
                if (!this.sawRoot && !this.reportedTextBeforeRoot) {
                    this.fail("text data outside of root node.");
                    this.reportedTextBeforeRoot = true;
                }
                if (this.closedRoot && !this.reportedTextAfterRoot) {
                    this.fail("text data outside of root node.");
                    this.reportedTextAfterRoot = true;
                }
                this.state = S_CDATA;
                this.openWakaBang = "";
                break;
            case "--":
                this.state = S_COMMENT;
                this.openWakaBang = "";
                break;
            case "DOCTYPE":
                this.state = S_DOCTYPE;
                if (this.doctype || this.sawRoot) {
                    this.fail("inappropriately located doctype declaration.");
                }
                this.openWakaBang = "";
                break;
            default:
                if (this.openWakaBang.length >= 7) {
                    this.fail("incorrect syntax.");
                }
        }
    }
    sComment() {
        if (this.captureToChar(0x2D)) {
            this.state = S_COMMENT_ENDING;
        }
    }
    sCommentEnding() {
        const c = this.getCodeNorm();
        if (c === 0x2D) {
            this.state = S_COMMENT_ENDED;
            this.commentHandler?.(this.text);
            this.text = "";
        } else {
            this.text += `-${String.fromCodePoint(c)}`;
            this.state = S_COMMENT;
        }
    }
    sCommentEnded() {
        const c = this.getCodeNorm();
        if (c !== 0x3E) {
            this.fail("malformed comment.");
            this.text += `--${String.fromCodePoint(c)}`;
            this.state = S_COMMENT;
        } else {
            this.state = S_TEXT;
        }
    }
    sCData() {
        if (this.captureToChar(0x5D)) {
            this.state = S_CDATA_ENDING;
        }
    }
    sCDataEnding() {
        const c = this.getCodeNorm();
        if (c === 0x5D) {
            this.state = S_CDATA_ENDING_2;
        } else {
            this.text += `]${String.fromCodePoint(c)}`;
            this.state = S_CDATA;
        }
    }
    sCDataEnding2() {
        const c = this.getCodeNorm();
        switch(c){
            case 0x3E:
                {
                    this.cdataHandler?.(this.text);
                    this.text = "";
                    this.state = S_TEXT;
                    break;
                }
            case 0x5D:
                this.text += "]";
                break;
            default:
                this.text += `]]${String.fromCodePoint(c)}`;
                this.state = S_CDATA;
        }
    }
    sPIFirstChar() {
        const c = this.getCodeNorm();
        if (this.nameStartCheck(c)) {
            this.piTarget += String.fromCodePoint(c);
            this.state = S_PI_REST;
        } else if (c === 0x3F || isS1(c)) {
            this.fail("processing instruction without a target.");
            this.state = c === QUESTION ? S_PI_ENDING : S_PI_BODY;
        } else {
            this.fail("disallowed character in processing instruction name.");
            this.piTarget += String.fromCodePoint(c);
            this.state = S_PI_REST;
        }
    }
    sPIRest() {
        const { chunk , i: start  } = this;
        while(true){
            const c = this.getCodeNorm();
            if (c === EOC) {
                this.piTarget += chunk.slice(start);
                return;
            }
            if (!this.nameCheck(c)) {
                this.piTarget += chunk.slice(start, this.prevI);
                const isQuestion = c === 0x3F;
                if (isQuestion || isS1(c)) {
                    if (this.piTarget === "xml") {
                        if (!this.xmlDeclPossible) {
                            this.fail("an XML declaration must be at the start of the document.");
                        }
                        this.state = isQuestion ? S_XML_DECL_ENDING : S_XML_DECL_NAME_START;
                    } else {
                        this.state = isQuestion ? S_PI_ENDING : S_PI_BODY;
                    }
                } else {
                    this.fail("disallowed character in processing instruction name.");
                    this.piTarget += String.fromCodePoint(c);
                }
                break;
            }
        }
    }
    sPIBody() {
        if (this.text.length === 0) {
            const c = this.getCodeNorm();
            if (c === 0x3F) {
                this.state = S_PI_ENDING;
            } else if (!isS1(c)) {
                this.text = String.fromCodePoint(c);
            }
        } else if (this.captureToChar(0x3F)) {
            this.state = S_PI_ENDING;
        }
    }
    sPIEnding() {
        const c = this.getCodeNorm();
        if (c === 0x3E) {
            const { piTarget  } = this;
            if (piTarget.toLowerCase() === "xml") {
                this.fail("the XML declaration must appear at the start of the document.");
            }
            this.piHandler?.({
                target: piTarget,
                body: this.text
            });
            this.piTarget = this.text = "";
            this.state = S_TEXT;
        } else if (c === 0x3F) {
            this.text += "?";
        } else {
            this.text += `?${String.fromCodePoint(c)}`;
            this.state = S_PI_BODY;
        }
        this.xmlDeclPossible = false;
    }
    sXMLDeclNameStart() {
        const c = this.skipSpaces();
        if (c === 0x3F) {
            this.state = S_XML_DECL_ENDING;
            return;
        }
        if (c !== EOC) {
            this.state = S_XML_DECL_NAME;
            this.name = String.fromCodePoint(c);
        }
    }
    sXMLDeclName() {
        const c = this.captureTo(XML_DECL_NAME_TERMINATOR);
        if (c === 0x3F) {
            this.state = S_XML_DECL_ENDING;
            this.name += this.text;
            this.text = "";
            this.fail("XML declaration is incomplete.");
            return;
        }
        if (!(isS1(c) || c === 0x3D)) {
            return;
        }
        this.name += this.text;
        this.text = "";
        if (!this.xmlDeclExpects.includes(this.name)) {
            switch(this.name.length){
                case 0:
                    this.fail("did not expect any more name/value pairs.");
                    break;
                case 1:
                    this.fail(`expected the name ${this.xmlDeclExpects[0]}.`);
                    break;
                default:
                    this.fail(`expected one of ${this.xmlDeclExpects.join(", ")}`);
            }
        }
        this.state = c === EQUAL ? S_XML_DECL_VALUE_START : S_XML_DECL_EQ;
    }
    sXMLDeclEq() {
        const c = this.getCodeNorm();
        if (c === 0x3F) {
            this.state = S_XML_DECL_ENDING;
            this.fail("XML declaration is incomplete.");
            return;
        }
        if (isS1(c)) {
            return;
        }
        if (c !== 0x3D) {
            this.fail("value required.");
        }
        this.state = S_XML_DECL_VALUE_START;
    }
    sXMLDeclValueStart() {
        const c = this.getCodeNorm();
        if (c === 0x3F) {
            this.state = S_XML_DECL_ENDING;
            this.fail("XML declaration is incomplete.");
            return;
        }
        if (isS1(c)) {
            return;
        }
        if (!isQuote(c)) {
            this.fail("value must be quoted.");
            this.q = SPACE;
        } else {
            this.q = c;
        }
        this.state = S_XML_DECL_VALUE;
    }
    sXMLDeclValue() {
        const c = this.captureTo([
            this.q,
            0x3F
        ]);
        if (c === 0x3F) {
            this.state = S_XML_DECL_ENDING;
            this.text = "";
            this.fail("XML declaration is incomplete.");
            return;
        }
        if (c === EOC) {
            return;
        }
        const value = this.text;
        this.text = "";
        switch(this.name){
            case "version":
                {
                    this.xmlDeclExpects = [
                        "encoding",
                        "standalone"
                    ];
                    const version = value;
                    this.xmlDecl.version = version;
                    if (!/^1\.[0-9]+$/.test(version)) {
                        this.fail("version number must match /^1\\.[0-9]+$/.");
                    } else if (!this.opt.forceXMLVersion) {
                        this.setXMLVersion(version);
                    }
                    break;
                }
            case "encoding":
                if (!/^[A-Za-z][A-Za-z0-9._-]*$/.test(value)) {
                    this.fail("encoding value must match \
/^[A-Za-z0-9][A-Za-z0-9._-]*$/.");
                }
                this.xmlDeclExpects = [
                    "standalone"
                ];
                this.xmlDecl.encoding = value;
                break;
            case "standalone":
                if (value !== "yes" && value !== "no") {
                    this.fail("standalone value must match \"yes\" or \"no\".");
                }
                this.xmlDeclExpects = [];
                this.xmlDecl.standalone = value;
                break;
            default:
        }
        this.name = "";
        this.state = S_XML_DECL_SEPARATOR;
    }
    sXMLDeclSeparator() {
        const c = this.getCodeNorm();
        if (c === 0x3F) {
            this.state = S_XML_DECL_ENDING;
            return;
        }
        if (!isS1(c)) {
            this.fail("whitespace required.");
            this.unget();
        }
        this.state = S_XML_DECL_NAME_START;
    }
    sXMLDeclEnding() {
        const c = this.getCodeNorm();
        if (c === 0x3E) {
            if (this.piTarget !== "xml") {
                this.fail("processing instructions are not allowed before root.");
            } else if (this.name !== "version" && this.xmlDeclExpects.includes("version")) {
                this.fail("XML declaration must contain a version.");
            }
            this.xmldeclHandler?.(this.xmlDecl);
            this.name = "";
            this.piTarget = this.text = "";
            this.state = S_TEXT;
        } else {
            this.fail("The character ? is disallowed anywhere in XML declarations.");
        }
        this.xmlDeclPossible = false;
    }
    sOpenTag() {
        const c = this.captureNameChars();
        if (c === EOC) {
            return;
        }
        const tag = this.tag = {
            name: this.name,
            attributes: Object.create(null)
        };
        this.name = "";
        if (this.xmlnsOpt) {
            this.topNS = tag.ns = Object.create(null);
        }
        this.openTagStartHandler?.(tag);
        this.sawRoot = true;
        if (!this.fragmentOpt && this.closedRoot) {
            this.fail("documents may contain only one root.");
        }
        switch(c){
            case 0x3E:
                this.openTag();
                break;
            case 0x2F:
                this.state = S_OPEN_TAG_SLASH;
                break;
            default:
                if (!isS1(c)) {
                    this.fail("disallowed character in tag name.");
                }
                this.state = S_ATTRIB;
        }
    }
    sOpenTagSlash() {
        if (this.getCode() === 0x3E) {
            this.openSelfClosingTag();
        } else {
            this.fail("forward-slash in opening tag not followed by >.");
            this.state = S_ATTRIB;
        }
    }
    sAttrib() {
        const c = this.skipSpaces();
        if (c === EOC) {
            return;
        }
        if (isNameStartChar1(c)) {
            this.unget();
            this.state = S_ATTRIB_NAME;
        } else if (c === 0x3E) {
            this.openTag();
        } else if (c === 0x2F) {
            this.state = S_OPEN_TAG_SLASH;
        } else {
            this.fail("disallowed character in attribute name.");
        }
    }
    sAttribName() {
        const c = this.captureNameChars();
        if (c === 0x3D) {
            this.state = S_ATTRIB_VALUE;
        } else if (isS1(c)) {
            this.state = S_ATTRIB_NAME_SAW_WHITE;
        } else if (c === 0x3E) {
            this.fail("attribute without value.");
            this.pushAttrib(this.name, this.name);
            this.name = this.text = "";
            this.openTag();
        } else if (c !== EOC) {
            this.fail("disallowed character in attribute name.");
        }
    }
    sAttribNameSawWhite() {
        const c = this.skipSpaces();
        switch(c){
            case EOC:
                return;
            case 0x3D:
                this.state = S_ATTRIB_VALUE;
                break;
            default:
                this.fail("attribute without value.");
                this.text = "";
                this.name = "";
                if (c === 0x3E) {
                    this.openTag();
                } else if (isNameStartChar1(c)) {
                    this.unget();
                    this.state = S_ATTRIB_NAME;
                } else {
                    this.fail("disallowed character in attribute name.");
                    this.state = S_ATTRIB;
                }
        }
    }
    sAttribValue() {
        const c = this.getCodeNorm();
        if (isQuote(c)) {
            this.q = c;
            this.state = S_ATTRIB_VALUE_QUOTED;
        } else if (!isS1(c)) {
            this.fail("unquoted attribute value.");
            this.state = S_ATTRIB_VALUE_UNQUOTED;
            this.unget();
        }
    }
    sAttribValueQuoted() {
        const { q , chunk  } = this;
        let { i: start  } = this;
        while(true){
            switch(this.getCode()){
                case q:
                    this.pushAttrib(this.name, this.text + chunk.slice(start, this.prevI));
                    this.name = this.text = "";
                    this.q = null;
                    this.state = S_ATTRIB_VALUE_CLOSED;
                    return;
                case 0x26:
                    this.text += chunk.slice(start, this.prevI);
                    this.state = S_ENTITY;
                    this.entityReturnState = S_ATTRIB_VALUE_QUOTED;
                    return;
                case 0xA:
                case NL_LIKE:
                case 9:
                    this.text += `${chunk.slice(start, this.prevI)} `;
                    start = this.i;
                    break;
                case 0x3C:
                    this.text += chunk.slice(start, this.prevI);
                    this.fail("disallowed character.");
                    return;
                case EOC:
                    this.text += chunk.slice(start);
                    return;
                default:
            }
        }
    }
    sAttribValueClosed() {
        const c = this.getCodeNorm();
        if (isS1(c)) {
            this.state = S_ATTRIB;
        } else if (c === 0x3E) {
            this.openTag();
        } else if (c === 0x2F) {
            this.state = S_OPEN_TAG_SLASH;
        } else if (isNameStartChar1(c)) {
            this.fail("no whitespace between attributes.");
            this.unget();
            this.state = S_ATTRIB_NAME;
        } else {
            this.fail("disallowed character in attribute name.");
        }
    }
    sAttribValueUnquoted() {
        const c = this.captureTo(ATTRIB_VALUE_UNQUOTED_TERMINATOR);
        switch(c){
            case 0x26:
                this.state = S_ENTITY;
                this.entityReturnState = S_ATTRIB_VALUE_UNQUOTED;
                break;
            case 0x3C:
                this.fail("disallowed character.");
                break;
            case EOC:
                break;
            default:
                if (this.text.includes("]]>")) {
                    this.fail("the string \"]]>\" is disallowed in char data.");
                }
                this.pushAttrib(this.name, this.text);
                this.name = this.text = "";
                if (c === 0x3E) {
                    this.openTag();
                } else {
                    this.state = S_ATTRIB;
                }
        }
    }
    sCloseTag() {
        const c = this.captureNameChars();
        if (c === 0x3E) {
            this.closeTag();
        } else if (isS1(c)) {
            this.state = S_CLOSE_TAG_SAW_WHITE;
        } else if (c !== EOC) {
            this.fail("disallowed character in closing tag.");
        }
    }
    sCloseTagSawWhite() {
        switch(this.skipSpaces()){
            case 0x3E:
                this.closeTag();
                break;
            case EOC:
                break;
            default:
                this.fail("disallowed character in closing tag.");
        }
    }
    handleTextInRoot() {
        let { i: start , forbiddenState  } = this;
        const { chunk , textHandler: handler  } = this;
        scanLoop: while(true){
            switch(this.getCode()){
                case 0x3C:
                    {
                        this.state = S_OPEN_WAKA;
                        if (handler !== undefined) {
                            const { text  } = this;
                            const slice = chunk.slice(start, this.prevI);
                            if (text.length !== 0) {
                                handler(text + slice);
                                this.text = "";
                            } else if (slice.length !== 0) {
                                handler(slice);
                            }
                        }
                        forbiddenState = FORBIDDEN_START;
                        break scanLoop;
                    }
                case 0x26:
                    this.state = S_ENTITY;
                    this.entityReturnState = S_TEXT;
                    if (handler !== undefined) {
                        this.text += chunk.slice(start, this.prevI);
                    }
                    forbiddenState = FORBIDDEN_START;
                    break scanLoop;
                case 0x5D:
                    switch(forbiddenState){
                        case 0:
                            forbiddenState = FORBIDDEN_BRACKET;
                            break;
                        case 1:
                            forbiddenState = FORBIDDEN_BRACKET_BRACKET;
                            break;
                        case 2:
                            break;
                        default:
                            throw new Error("impossible state");
                    }
                    break;
                case 0x3E:
                    if (forbiddenState === 2) {
                        this.fail("the string \"]]>\" is disallowed in char data.");
                    }
                    forbiddenState = FORBIDDEN_START;
                    break;
                case NL_LIKE:
                    if (handler !== undefined) {
                        this.text += `${chunk.slice(start, this.prevI)}\n`;
                    }
                    start = this.i;
                    forbiddenState = FORBIDDEN_START;
                    break;
                case EOC:
                    if (handler !== undefined) {
                        this.text += chunk.slice(start);
                    }
                    break scanLoop;
                default:
                    forbiddenState = FORBIDDEN_START;
            }
        }
        this.forbiddenState = forbiddenState;
    }
    handleTextOutsideRoot() {
        let { i: start  } = this;
        const { chunk , textHandler: handler  } = this;
        let nonSpace = false;
        outRootLoop: while(true){
            const code = this.getCode();
            switch(code){
                case 0x3C:
                    {
                        this.state = S_OPEN_WAKA;
                        if (handler !== undefined) {
                            const { text  } = this;
                            const slice = chunk.slice(start, this.prevI);
                            if (text.length !== 0) {
                                handler(text + slice);
                                this.text = "";
                            } else if (slice.length !== 0) {
                                handler(slice);
                            }
                        }
                        break outRootLoop;
                    }
                case 0x26:
                    this.state = S_ENTITY;
                    this.entityReturnState = S_TEXT;
                    if (handler !== undefined) {
                        this.text += chunk.slice(start, this.prevI);
                    }
                    nonSpace = true;
                    break outRootLoop;
                case NL_LIKE:
                    if (handler !== undefined) {
                        this.text += `${chunk.slice(start, this.prevI)}\n`;
                    }
                    start = this.i;
                    break;
                case EOC:
                    if (handler !== undefined) {
                        this.text += chunk.slice(start);
                    }
                    break outRootLoop;
                default:
                    if (!isS1(code)) {
                        nonSpace = true;
                    }
            }
        }
        if (!nonSpace) {
            return;
        }
        if (!this.sawRoot && !this.reportedTextBeforeRoot) {
            this.fail("text data outside of root node.");
            this.reportedTextBeforeRoot = true;
        }
        if (this.closedRoot && !this.reportedTextAfterRoot) {
            this.fail("text data outside of root node.");
            this.reportedTextAfterRoot = true;
        }
    }
    pushAttribNS(name, value) {
        const { prefix , local  } = this.qname(name);
        const attr = {
            name,
            prefix,
            local,
            value
        };
        this.attribList.push(attr);
        this.attributeHandler?.(attr);
        if (prefix === "xmlns") {
            const trimmed = value.trim();
            if (this.currentXMLVersion === "1.0" && trimmed === "") {
                this.fail("invalid attempt to undefine prefix in XML 1.0");
            }
            this.topNS[local] = trimmed;
            nsPairCheck(this, local, trimmed);
        } else if (name === "xmlns") {
            const trimmed1 = value.trim();
            this.topNS[""] = trimmed1;
            nsPairCheck(this, "", trimmed1);
        }
    }
    pushAttribPlain(name, value) {
        const attr = {
            name,
            value
        };
        this.attribList.push(attr);
        this.attributeHandler?.(attr);
    }
    end() {
        if (!this.sawRoot) {
            this.fail("document must contain a root element.");
        }
        const { tags  } = this;
        while(tags.length > 0){
            const tag = tags.pop();
            this.fail(`unclosed tag: ${tag.name}`);
        }
        if (this.state !== 0 && this.state !== 13) {
            this.fail("unexpected end.");
        }
        const { text  } = this;
        if (text.length !== 0) {
            this.textHandler?.(text);
            this.text = "";
        }
        this._closed = true;
        this.endHandler?.();
        this._init();
        return this;
    }
    resolve(prefix) {
        let uri = this.topNS[prefix];
        if (uri !== undefined) {
            return uri;
        }
        const { tags  } = this;
        for(let index = tags.length - 1; index >= 0; index--){
            uri = tags[index].ns[prefix];
            if (uri !== undefined) {
                return uri;
            }
        }
        uri = this.ns[prefix];
        if (uri !== undefined) {
            return uri;
        }
        return this.opt.resolvePrefix?.(prefix);
    }
    qname(name) {
        const colon = name.indexOf(":");
        if (colon === -1) {
            return {
                prefix: "",
                local: name
            };
        }
        const local = name.slice(colon + 1);
        const prefix = name.slice(0, colon);
        if (prefix === "" || local === "" || local.includes(":")) {
            this.fail(`malformed name: ${name}.`);
        }
        return {
            prefix,
            local
        };
    }
    processAttribsNS() {
        const { attribList  } = this;
        const tag = this.tag;
        {
            const { prefix , local  } = this.qname(tag.name);
            tag.prefix = prefix;
            tag.local = local;
            const uri = tag.uri = this.resolve(prefix) ?? "";
            if (prefix !== "") {
                if (prefix === "xmlns") {
                    this.fail("tags may not have \"xmlns\" as prefix.");
                }
                if (uri === "") {
                    this.fail(`unbound namespace prefix: ${JSON.stringify(prefix)}.`);
                    tag.uri = prefix;
                }
            }
        }
        if (attribList.length === 0) {
            return;
        }
        const { attributes  } = tag;
        const seen = new Set();
        for (const attr of attribList){
            const { name , prefix: prefix1 , local: local1  } = attr;
            let uri1;
            let eqname;
            if (prefix1 === "") {
                uri1 = name === "xmlns" ? XMLNS_NAMESPACE : "";
                eqname = name;
            } else {
                uri1 = this.resolve(prefix1);
                if (uri1 === undefined) {
                    this.fail(`unbound namespace prefix: ${JSON.stringify(prefix1)}.`);
                    uri1 = prefix1;
                }
                eqname = `{${uri1}}${local1}`;
            }
            if (seen.has(eqname)) {
                this.fail(`duplicate attribute: ${eqname}.`);
            }
            seen.add(eqname);
            attr.uri = uri1;
            attributes[name] = attr;
        }
        this.attribList = [];
    }
    processAttribsPlain() {
        const { attribList  } = this;
        const attributes = this.tag.attributes;
        for (const { name , value  } of attribList){
            if (attributes[name] !== undefined) {
                this.fail(`duplicate attribute: ${name}.`);
            }
            attributes[name] = value;
        }
        this.attribList = [];
    }
    openTag() {
        this.processAttribs();
        const { tags  } = this;
        const tag = this.tag;
        tag.isSelfClosing = false;
        this.openTagHandler?.(tag);
        tags.push(tag);
        this.state = S_TEXT;
        this.name = "";
    }
    openSelfClosingTag() {
        this.processAttribs();
        const { tags  } = this;
        const tag = this.tag;
        tag.isSelfClosing = true;
        this.openTagHandler?.(tag);
        this.closeTagHandler?.(tag);
        const top = this.tag = tags[tags.length - 1] ?? null;
        if (top === null) {
            this.closedRoot = true;
        }
        this.state = S_TEXT;
        this.name = "";
    }
    closeTag() {
        const { tags , name  } = this;
        this.state = S_TEXT;
        this.name = "";
        if (name === "") {
            this.fail("weird empty close tag.");
            this.text += "</>";
            return;
        }
        const handler = this.closeTagHandler;
        let l = tags.length;
        while(l-- > 0){
            const tag = this.tag = tags.pop();
            this.topNS = tag.ns;
            handler?.(tag);
            if (tag.name === name) {
                break;
            }
            this.fail("unexpected close tag.");
        }
        if (l === 0) {
            this.closedRoot = true;
        } else if (l < 0) {
            this.fail(`unmatched closing tag: ${name}.`);
            this.text += `</${name}>`;
        }
    }
    parseEntity(entity) {
        if (entity[0] !== "#") {
            const defined = this.ENTITIES[entity];
            if (defined !== undefined) {
                return defined;
            }
            this.fail(this.isName(entity) ? "undefined entity." : "disallowed character in entity name.");
            return `&${entity};`;
        }
        let num = NaN;
        if (entity[1] === "x" && /^#x[0-9a-f]+$/i.test(entity)) {
            num = parseInt(entity.slice(2), 16);
        } else if (/^#[0-9]+$/.test(entity)) {
            num = parseInt(entity.slice(1), 10);
        }
        if (!this.isChar(num)) {
            this.fail("malformed character entity.");
            return `&${entity};`;
        }
        return String.fromCodePoint(num);
    }
}
const __default9 = {
    copyOptions: function(options) {
        const copy = {};
        for(const key in options){
            if (Object.prototype.hasOwnProperty.call(options, key)) {
                copy[key] = options[key];
            }
        }
        return copy;
    },
    ensureFlagExists: function(item, options) {
        if (!(item in options) || typeof options[item] !== "boolean") {
            options[item] = false;
        }
    },
    ensureSpacesExists: function(options) {
        if (!("spaces" in options) || typeof options.spaces !== "number" && typeof options.spaces !== "string") {
            options.spaces = 0;
        }
    },
    ensureAlwaysArrayExists: function(options) {
        if (!("alwaysArray" in options) || typeof options.alwaysArray !== "boolean" && !Array.isArray(options.alwaysArray)) {
            options.alwaysArray = false;
        }
    },
    ensureKeyExists: function(key, options) {
        if (!(key + "Key" in options) || typeof options[key + "Key"] !== "string") {
            options[key + "Key"] = options.compact ? "_" + key : key;
        }
    }
};
let options;
let currentElement;
function validateOptions(userOptions) {
    options = __default9.copyOptions(userOptions);
    __default9.ensureFlagExists("ignoreDeclaration", options);
    __default9.ensureFlagExists("ignoreInstruction", options);
    __default9.ensureFlagExists("ignoreAttributes", options);
    __default9.ensureFlagExists("ignoreText", options);
    __default9.ensureFlagExists("ignoreComment", options);
    __default9.ensureFlagExists("ignoreCdata", options);
    __default9.ensureFlagExists("ignoreDoctype", options);
    __default9.ensureFlagExists("compact", options);
    __default9.ensureFlagExists("alwaysChildren", options);
    __default9.ensureFlagExists("trim", options);
    __default9.ensureFlagExists("nativeType", options);
    __default9.ensureFlagExists("nativeTypeAttributes", options);
    __default9.ensureFlagExists("sanitize", options);
    __default9.ensureFlagExists("instructionHasAttributes", options);
    __default9.ensureFlagExists("captureSpacesBetweenElements", options);
    __default9.ensureAlwaysArrayExists(options);
    __default9.ensureKeyExists("declaration", options);
    __default9.ensureKeyExists("instruction", options);
    __default9.ensureKeyExists("attributes", options);
    __default9.ensureKeyExists("text", options);
    __default9.ensureKeyExists("comment", options);
    __default9.ensureKeyExists("cdata", options);
    __default9.ensureKeyExists("doctype", options);
    __default9.ensureKeyExists("type", options);
    __default9.ensureKeyExists("name", options);
    __default9.ensureKeyExists("elements", options);
    __default9.ensureKeyExists("parent", options);
    return options;
}
function nativeType(value) {
    const nValue = Number(value);
    if (!isNaN(nValue)) {
        return nValue;
    }
    const bValue = value.toLowerCase();
    if (bValue === "true") {
        return true;
    } else if (bValue === "false") {
        return false;
    }
    return value;
}
function addField(type, value) {
    let key = "";
    if (options.compact) {
        if (!currentElement[options[type + "Key"]] && (options.alwaysArray instanceof Array ? options.alwaysArray.indexOf(options[type + "Key"]) !== -1 : options.alwaysArray)) {
            currentElement[options[type + "Key"]] = [];
        }
        if (currentElement[options[type + "Key"]] && !(currentElement[options[type + "Key"]] instanceof Array)) {
            currentElement[options[type + "Key"]] = [
                currentElement[options[type + "Key"]], 
            ];
        }
        if (currentElement[options[type + "Key"]] instanceof Array) {
            currentElement[options[type + "Key"]].push(value);
        } else {
            currentElement[options[type + "Key"]] = value;
        }
    } else {
        if (!currentElement[options.elementsKey]) {
            currentElement[options.elementsKey] = [];
        }
        const element = {};
        element[options.typeKey] = type;
        if (type === "instruction") {
            for(key in value){
                if (Object.prototype.hasOwnProperty.call(value, key)) {
                    break;
                }
            }
            element[options.nameKey] = key;
            if (options.instructionHasAttributes) {
                element[options.attributesKey] = value[key][options.attributesKey];
            } else {
                element[options.instructionKey] = value[key];
            }
        } else {
            element[options[type + "Key"]] = value;
        }
        currentElement[options.elementsKey].push(element);
    }
}
function manipulateAttributes(attributes) {
    if (attributes) {
        const keysToDelete = [];
        let key = "";
        for(key in attributes){
            if (Object.prototype.hasOwnProperty.call(attributes, key)) {
                if ("undefined" == typeof attributes[key]) {
                    keysToDelete.push(key);
                } else {
                    if (options.trim) {
                        attributes[key] = attributes[key].trim();
                    }
                    if (options.nativeTypeAttributes) {
                        attributes[key] = nativeType(attributes[key]);
                    }
                }
            }
        }
        for (const kd of keysToDelete){
            delete attributes[kd];
        }
    }
    return attributes;
}
function onDeclaration(attrs) {
    if (options.ignoreDeclaration) {
        return;
    }
    const attributes = manipulateAttributes(attrs);
    currentElement[options.declarationKey] = {};
    if (Object.keys(attributes).length > 0) {
        currentElement[options.declarationKey][options.attributesKey] = attributes;
    }
}
function onInstruction(instruction) {
    let attributes = {};
    instruction.name = instruction.target;
    if (instruction.body && options.instructionHasAttributes) {
        const attrsRegExp = /([\w:-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|(\w+))\s*/g;
        let match;
        while((match = attrsRegExp.exec(instruction.body)) !== null){
            attributes[match[1]] = match[2] || match[3] || match[4];
        }
        attributes = manipulateAttributes(attributes);
    }
    if (options.ignoreInstruction) {
        return;
    }
    if (options.trim) {
        instruction.body = instruction.body.trim();
    }
    const value = {};
    if (options.instructionHasAttributes && Object.keys(attributes).length) {
        value[instruction.name] = {};
        value[instruction.name][options.attributesKey] = attributes;
    } else {
        value[instruction.name] = instruction.body;
    }
    addField("instruction", value);
}
function onStartElement(tag) {
    const name = tag.name;
    let attributes = tag.attributes;
    attributes = manipulateAttributes(attributes);
    const element = {};
    if (options.compact) {
        if (!options.ignoreAttributes && attributes && Object.keys(attributes).length > 0) {
            element[options.attributesKey] = {};
            let key = "";
            for(key in attributes){
                if (Object.prototype.hasOwnProperty.call(attributes, key)) {
                    element[options.attributesKey][key] = attributes[key];
                }
            }
        }
        if (!(name in currentElement) && (options.alwaysArray instanceof Array ? options.alwaysArray.indexOf(name) !== -1 : options.alwaysArray)) {
            currentElement[name] = [];
        }
        if (currentElement[name] && !(currentElement[name] instanceof Array)) {
            currentElement[name] = [
                currentElement[name]
            ];
        }
        if (currentElement[name] instanceof Array) {
            currentElement[name].push(element);
        } else {
            currentElement[name] = element;
        }
    } else {
        if (!currentElement[options.elementsKey]) {
            currentElement[options.elementsKey] = [];
        }
        element[options.typeKey] = "element";
        element[options.nameKey] = name;
        if (!options.ignoreAttributes && attributes && Object.keys(attributes).length) {
            element[options.attributesKey] = attributes;
        }
        if (options.alwaysChildren) {
            element[options.elementsKey] = [];
        }
        currentElement[options.elementsKey].push(element);
    }
    element[options.parentKey] = currentElement;
    currentElement = element;
}
function onText(text) {
    if (options.ignoreText) {
        return;
    }
    if (!text.trim() && !options.captureSpacesBetweenElements) {
        return;
    }
    if (options.trim) {
        text = text.trim();
    }
    if (options.sanitize) {
        text = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }
    if (options.nativeType) {
        text = nativeType(text);
    }
    addField("text", text);
}
function onComment(comment) {
    if (options.ignoreComment) {
        return;
    }
    if (options.trim) {
        comment = comment.trim();
    }
    addField("comment", comment);
}
function onEndElement(_name) {
    const parentElement = currentElement[options.parentKey];
    delete currentElement[options.parentKey];
    currentElement = parentElement;
}
function onCdata(cdata) {
    if (options.ignoreCdata) {
        return;
    }
    if (options.trim) {
        cdata = cdata.trim();
    }
    addField("cdata", cdata);
}
function onDoctype(doctype) {
    if (options.ignoreDoctype) {
        return;
    }
    doctype = doctype.replace(/^ /, "");
    if (options.trim) {
        doctype = doctype.trim();
    }
    addField("doctype", doctype);
}
function onError(error) {
    error.note = error;
}
function __default10(xml, userOptions) {
    const parser = new SaxesParser();
    const result = {};
    currentElement = result;
    options = validateOptions(userOptions);
    parser.on("opentag", onStartElement);
    parser.on("text", onText);
    parser.on("comment", onComment);
    parser.on("closetag", onEndElement);
    parser.on("error", onError);
    parser.on("cdata", onCdata);
    parser.on("doctype", onDoctype);
    parser.on("processinginstruction", onInstruction);
    parser.on("xmldecl", onDeclaration);
    parser.write(xml).close();
    if (result[options.elementsKey]) {
        const temp = result[options.elementsKey];
        delete result[options.elementsKey];
        result[options.elementsKey] = temp;
        delete result.text;
    }
    return result;
}
const __default11 = {
    do: async (o)=>{
        __default1.info('FETCH fetch', o);
        let params = new URLSearchParams();
        if (o.data != null) {
            for(let x in o.data){
                params.append(x, o.data[x]);
            }
        } else {
            params = null;
        }
        await fetch(o.url, {
            body: params,
            method: o.method,
            headers: o.header ? o.header : {}
        }).then(async (res)=>{
            o.res = res;
            __default1.info("FETCH res", res);
            if (o.success) {
                let data = {
                    data: await res.text()
                };
                o.success(data);
            }
        }).catch((err)=>{
            __default1.error('error', err);
        }).finally(()=>{
            if (o.complete) {
                o.complete();
            }
        });
    }
};
const getFirstObjectByName = (targetObj, name)=>{
    let res = null;
    for(let x in targetObj){
        if (x === name) {
            return targetObj[x];
        }
        const v = targetObj[x];
        if (typeof v === "object") {
            for(let y in v){
                res = getFirstObjectByName(v, name);
                if (res != null) {
                    break;
                }
            }
        }
    }
    return res;
};
const getStrFromXMLJson = (value)=>{
    if (value === undefined) {
        return "";
    }
    try {
        return value["_text"] || value["_cdata"];
    } catch (err) {
        return err + "";
    }
};
class RssController {
    responseFunc;
    constructor(){}
    initResponseFunc(func) {
        this.responseFunc = func;
    }
    response(ipcData) {
        if (this.responseFunc) {
            this.responseFunc(ipcData);
        } else {
            console.error('this.responseFunc is null');
        }
    }
    convertJSON2RssObject(rss, baseUrl) {
        if (typeof rss !== "object") {
            return undefined;
        }
        console.info(rss);
        const version = rss["_attributes"]?.version;
        const _s = getStrFromXMLJson;
        if (version) {
            const channel = {
                title: getStrFromXMLJson(rss.channel.title),
                link: getStrFromXMLJson(rss.channel.link),
                description: getStrFromXMLJson(rss.channel.description),
                copyright: getStrFromXMLJson(rss.channel.copyright),
                managingEditor: getStrFromXMLJson(rss.channel.managingEditor),
                item: []
            };
            if (rss.channel && rss.channel.item && rss.channel?.item instanceof Array) {
                for(let index in rss.channel.item){
                    const i = {};
                    for(let x in rss.channel.item[index]){
                        i[x] = getStrFromXMLJson(rss.channel.item[index][x]);
                    }
                    channel.item?.push(i);
                }
            }
            const res = {
                version,
                channel
            };
            return res;
        } else {
            return {
                version: '1',
                channel: {
                    title: _s(rss.title),
                    description: _s(rss.subtitle),
                    link: _s(getFirstObjectByName(rss.link, 'href')),
                    item: rss.entry.map((entryItem)=>{
                        console.info(entryItem);
                        let rssItemlink = getFirstObjectByName(entryItem.link, 'href');
                        if (rssItemlink.startsWith('/')) {
                            rssItemlink = new URL(baseUrl).origin + rssItemlink;
                        }
                        return {
                            title: _s(entryItem.title),
                            pubDate: _s(entryItem.published),
                            description: _s(entryItem.summary),
                            link: rssItemlink,
                            author: _s(entryItem.author?.name)
                        };
                    })
                }
            };
        }
    }
    async tryHandleInvoke(ipcData) {
        console.info('tryHandleInvoke');
        console.info(ipcData);
        const { invokeName , data: invokeData  } = ipcData.data;
        if (invokeName === "addRss") {
            const { url  } = invokeData;
            console.info('tryhandleInvoke addRss', invokeData, url);
            let listDataRes = await __default5.get({
                key: "listData"
            });
            if (listDataRes.data === undefined) {
                listDataRes.data = {
                    headerInfos: []
                };
            }
            let isResed = false;
            new Promise((resolve, reject)=>{
                __default11.do({
                    url,
                    method: "GET",
                    success: (res)=>{
                        const obj = __default10(res.data, {
                            compact: true
                        });
                        resolve(obj);
                    }
                });
            }).then((res)=>{
                let rssObj = getFirstObjectByName(res, "rss");
                if (!rssObj) {
                    rssObj = getFirstObjectByName(res, "feed");
                }
                return rssObj;
            }).then((rss)=>{
                const res = this.convertJSON2RssObject(rss, url);
                if (res == undefined) {
                    throw Error("convert rss object fail");
                }
                return res;
            }).then(async (rss)=>{
                const header = {
                    title: rss.channel?.title,
                    date: rss.channel?.managingEditor || rss.channel.link,
                    tags: [
                        rss.channel?.title,
                        '_RSS'
                    ],
                    path: url,
                    type: "rss"
                };
                const hitItems = listDataRes.data.headerInfos.filter((item)=>{
                    return item.path == url;
                });
                console.info('hitItems', hitItems.length);
                if (hitItems.length > 0) {
                    ipcData.msg = `alread has this rss, try update news`;
                } else {
                    listDataRes.data.headerInfos && listDataRes.data.headerInfos.push(header);
                }
                let hasNew = false;
                rss.channel?.item?.forEach((item)=>{
                    listDataRes.data.headerInfos;
                    const hitItems = listDataRes.data.headerInfos.filter((headerItem)=>{
                        return headerItem.path == item.link;
                    });
                    let rssItemHeader = {};
                    if (hitItems.length === 0) {
                        rssItemHeader = {
                            title: item.title,
                            date: item.pubDate,
                            tags: [
                                rss.channel?.title,
                                item.category ? item.category : ''
                            ].filter((i)=>i !== ''),
                            path: item.link,
                            type: "rssItem"
                        };
                        listDataRes.data.headerInfos && listDataRes.data.headerInfos.push(rssItemHeader);
                        hasNew = true;
                    }
                });
                if (!isResed) {
                    ipcData.data = listDataRes.data;
                    await __default5.set({
                        key: 'listData',
                        value: ipcData.data
                    });
                    if (hasNew) {
                        ipcData.msg = `${url} rss update success`;
                    } else {
                        ipcData.msg = `${url} without new item`;
                    }
                    this.response(ipcData);
                    isResed = true;
                }
            }).catch((err)=>{
                if (!isResed) {
                    ipcData.msg = `error: ${err}`;
                    this.response(ipcData);
                }
                console.error('err' + err);
            }).finally(()=>{
                if (!isResed) {
                    this.response(ipcData);
                }
            });
            return true;
        }
        return false;
    }
}
const defaultJsContent = '// __webpack_require__.r(__webpack_exports__);\n' + '// /* harmony import */ var monaco_editor__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! monaco-editor */ "../node_modules/monaco-editor/esm/vs/editor/editor.main.js");\n' + '\n' + '\n' + '// self.MonacoEnvironment = {\n' + '// \tgetWorkerUrl: function (moduleId, label) {\n' + "// \t\tif (label === 'json') {\n" + "// \t\t\treturn './json.worker.bundle.js';\n" + '// \t\t}\n' + "// \t\tif (label === 'css' || label === 'scss' || label === 'less') {\n" + "// \t\t\treturn './css.worker.bundle.js';\n" + '// \t\t}\n' + "// \t\tif (label === 'html' || label === 'handlebars' || label === 'razor') {\n" + "// \t\t\treturn './html.worker.bundle.js';\n" + '// \t\t}\n' + "// \t\tif (label === 'typescript' || label === 'javascript') {\n" + "// \t\t\treturn './ts.worker.bundle.js';\n" + '// \t\t}\n' + "// \t\treturn './editor.worker.bundle.js';\n" + '// \t}\n' + '// };\n' + '\n' + '// const initDenkui = () => {\n' + '// \tif (window.denkui === undefined) {\n' + '// \t\twindow.denkui = {}\n' + '// \t}\n' + '// }\n' + '\n' + '// const denkSetKeyValue = (key, value) => {\n' + '// \tinitDenkui()\n' + '// \twindow.denkui[key] = value\n' + '// }\n' + '\n' + '// const denkGetKey = (key) => {\n' + '// \tinitDenkui()\n' + '// \treturn window.denkui[key]\n' + '// }\n' + '\n' + '// window.denkGetKey = (name) => {\n' + '// \tconst res = denkGetKey(name)\n' + "// \tconsole.info('window.denkGetKey ', name, res)\n" + '// \treturn res\n' + '// }\n' + '// window.denkSetKeyValue = (name, value) => {\n' + "// \tconsole.info('window.denkSetKeyValue', name, value)\n" + '// \tdenkSetKeyValue(name, value)\n' + '// }\n' + '\n' + "// // window.denkSetKeyValue('editor', codeEditor)\n" + "// window.denkSetKeyValue('monaco', monaco_editor__WEBPACK_IMPORTED_MODULE_0__)\n" + '// window.denkAllKeys = () => {\n' + '// \tinitDenkui()\n' + '// \tconst res = []\n' + '// \tfor (let x in window.denkui) {\n' + '// \t\tres.push(x)\n' + '// \t}\n' + '// \treturn res\n' + '// }\n' + '\n' + '// const sendIpcMessage = (data) => {\n' + '// \ttry {\n' + '// \t\twindow.webkit.messageHandlers.ipcRender.postMessage(data)\n' + '// \t} catch (err) {\n' + '// \t\tconsole.error(err)\n' + '// \t}\n' + '// }\n' + '\n' + '// const prepareInjectJs = async () => {\n' + "// \tif (denkGetKey('prepareInjectJsResolve')) {\n" + "// \t\treturn Promise.reject('already loading')\n" + '// \t}\n' + '// \treturn new Promise((resolve, reject) => {\n' + '// \t\tsetTimeout(() => {\n' + "// \t\t\treject(new Error('timeout prepareInjectJs'))\n" + '// \t\t}, 1000);\n' + "// \t\tdenkSetKeyValue('prepareInjectJsResolve', resolve);\n" + '// \t\tsendIpcMessage({\n' + "// \t\t\tname: 'prepareInjectJs'\n" + '// \t\t})\n' + '// \t})\n' + '// }\n' + '\n' + "// window.denkSetKeyValue('sendIpcMessage', sendIpcMessage)\n" + '\n' + "// const editorContainerHolder = document.getElementById('editor_container_holder')\n" + '\n' + '// const defaultEditorOption = {\n' + "// \tvalue: ['defaultEditorOption'].join('\\\n" + "// '),\n" + "// \tlanguage: 'javascript'\n" + '// }\n' + '\n' + '\n' + '// {\n' + '// \tconst monaco = window.denkGetKey("monaco");\n' + '// \t// Register a new language\n' + '// \tmonaco.languages.register({ id: "markdown" });\n' + '\n' + '// \t// Register a tokens provider for the language\n' + '// \tmonaco.languages.setMonarchTokensProvider("markdown", {\n' + '// \t\ttokenizer: {\n' + '// \t\t\troot: [\n' + '// \t\t\t\t[/- .*?\\[DONE\\]/, "custom-done"],\n' + '// \t\t\t\t[/\\---/, "custom-title-bar"],\n' + '// \t\t\t\t[/^(title) ?: ?(.*)/, "custom-title-bar"],\n' + '// \t\t\t\t[/^(date) ?: ?(.*)/, "custom-title-bar"],\n' + '// \t\t\t\t[/^(tags) ?: ?(.*)/, "custom-title-bar"],\n' + '// \t\t\t\t[/^#{1,6} .*/, "custom-header"],\n' + '// \t\t\t\t[/- .*? /, "custom-list-item"],\n' + '// \t\t\t\t[/\\*\\*.*\\*\\*/, "custom-blod"],\n' + '// \t\t\t\t[/\\*.*\\*/, "custom-italic"],\n' + '// \t\t\t\t[/\\[error.*/, "custom-error"],\n' + '// \t\t\t\t[/\\d/, "custom-number"],\n' + '// \t\t\t\t[/\\[notice.*/, "custom-notice"],\n' + '// \t\t\t\t[/\\[info.*/, "custom-info"],\n' + '// \t\t\t\t[/\\[[a-zA-Z 0-9:]+\\]/, "custom-date"],\n' + '// \t\t\t\t[/const/, "custom-date"],\n' + '// \t\t\t\t[/".*?"/, "custom-date"],\n' + '\n' + '// \t\t\t],\n' + '// \t\t},\n' + '// \t});\n' + '\n' + '// \t// Define a new theme that contains only rules that match this language\n' + '// \tmonaco.editor.defineTheme("myCoolTheme", {\n' + '// \t\tbase: "vs",\n' + '// \t\tinherit: true,\n' + '// \t\trules: [\n' + '// \t\t\t{ token: "custom-done", foreground: "aaaaaa" },\n' + '// \t\t\t{ token: "custom-info", foreground: "808080" },\n' + '// \t\t\t{ token: "custom-title-bar", foreground: "808080" },\n' + '// \t\t\t{ token: "custom-header", foreground: "ffbcd4" },\n' + '// \t\t\t{ token: "custom-list-item", foreground: "FFA500" },\n' + '// \t\t\t{ token: "custom-title-bar", foreground: "808080" },\n' + '// \t\t\t{ token: "custom-blod", foreground: "00aaff", fontStyle: "bold" },\n' + '// \t\t\t{ token: "custom-italic", foreground: "ffaabb", fontStyle: "italic" },\n' + '// \t\t\t{ token: "custom-error", foreground: "ff0000", fontStyle: "bold" },\n' + '// \t\t\t{ token: "custom-number", foreground: "aa0000" },\n' + '// \t\t\t{ token: "custom-notice", foreground: "FFA500" },\n' + '// \t\t\t{ token: "custom-date", foreground: "008800" },\n' + '// \t\t],\n' + '// \t\tcolors: {\n' + '// \t\t\t"editor.foreground": "#000000",\n' + '// \t\t},\n' + '// \t});\n' + '\n' + '\n' + '// \tconst initCodeLens = (editor) => {\n' + '\n' + '// \t}\n' + '\n' + '\n' + '// \tconst initCommands = (editor) => {\n' + '\n' + '// \t\teditor.addAction({\n' + '// \t\t\t// An unique identifier of the contributed action.\n' + "// \t\t\tid: 'save',\n" + '\n' + '// \t\t\t// A label of the action that will be presented to the user.\n' + "// \t\t\tlabel: 'save!!!',\n" + '\n' + '// \t\t\t// An optional array of keybindings for the action.\n' + '// \t\t\tkeybindings: [\n' + '// \t\t\t\tmonaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS\n' + '// \t\t\t],\n' + '\n' + '// \t\t\t// A precondition for this action.\n' + '// \t\t\tprecondition: null,\n' + '\n' + '// \t\t\t// A rule to evaluate on top of the precondition in order to dispatch the keybindings.\n' + '// \t\t\tkeybindingContext: null,\n' + '\n' + "// \t\t\tcontextMenuGroupId: 'navigation',\n" + '\n' + '// \t\t\tcontextMenuOrder: 1.5,\n' + '\n' + '// \t\t\t// Method that will be executed when the action is triggered.\n' + '// \t\t\t// @param editor The editor instance is passed in as a convenience\n' + '// \t\t\trun: function (ed) {\n' + "// \t\t\t\twindow.denkGetKey('sendIpcMessage')({\n" + "// \t\t\t\t\tname: 'editorSave'\n" + '// \t\t\t\t})\n' + '// \t\t\t}\n' + '// \t\t});\n' + '\n' + '// \t\teditor.addAction({\n' + '// \t\t\t// An unique identifier of the contributed action.\n' + "// \t\t\tid: 'refresh',\n" + '\n' + '// \t\t\t// A label of the action that will be presented to the user.\n' + "// \t\t\tlabel: 'refresh',\n" + '\n' + '// \t\t\t// An optional array of keybindings for the action.\n' + '// \t\t\tkeybindings: [\n' + '// \t\t\t\tmonaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyR\n' + '// \t\t\t],\n' + '\n' + '// \t\t\t// A precondition for this action.\n' + '// \t\t\tprecondition: null,\n' + '\n' + '// \t\t\t// A rule to evaluate on top of the precondition in order to dispatch the keybindings.\n' + '// \t\t\tkeybindingContext: null,\n' + '\n' + "// \t\t\tcontextMenuGroupId: 'navigation',\n" + '\n' + '// \t\t\tcontextMenuOrder: 1.5,\n' + '\n' + '// \t\t\t// Method that will be executed when the action is triggered.\n' + '// \t\t\t// @param editor The editor instance is passed in as a convenience\n' + '// \t\t\trun: function (ed) {\n' + '// \t\t\t\tlocation.reload(false)\n' + '// \t\t\t}\n' + '// \t\t});\n' + '// \t}\n' + '\n' + "// \twindow.denkSetKeyValue('onEditorCreate', (editor) => {\n" + "// \t\tconsole.info('onEditorCreate', editor)\n" + '// \t\tinitCodeLens(editor)\n' + '// \t\tinitCommands(editor)\n' + '// \t})\n' + '\n' + '// \t// Register a completion item provider for the new language\n' + '// \tmonaco.languages.registerCompletionItemProvider("markdown", {\n' + '// \t\tprovideCompletionItems: () => {\n' + '// \t\t\tvar suggestions = [];\n' + '\n' + '// \t\t\tconst headerMaxLv = 6;\n' + '// \t\t\tlet headerPrefix = "";\n' + '// \t\t\tfor (let x = 1; x <= headerMaxLv; x++) {\n' + '// \t\t\t\theaderPrefix += "#";\n' + '// \t\t\t\tsuggestions.push({\n' + '// \t\t\t\t\tlabel: "_#" + x,\n' + '// \t\t\t\t\tkind: monaco.languages.CompletionItemKind.Text,\n' + '// \t\t\t\t\tinsertText: headerPrefix + " ${1:header}",\n' + '// \t\t\t\t\tinsertTextRules:\n' + '// \t\t\t\t\t\tmonaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,\n' + '// \t\t\t\t\tdocumentation: "Header levele " + x,\n' + '// \t\t\t\t});\n' + '// \t\t\t}\n' + '// \t\t\treturn { suggestions: suggestions };\n' + '// \t\t},\n' + '// \t});\n' + '// }\n' + '\n' + '\n' + '// window.onload = () => {\n' + "// \tconsole.info('editor window onload()')\n" + '\n' + '// \tnew Promise((resolve, reject) => {\n' + "// \t\tconsole.info('wait inject js')\n" + "// \t\t// window.denkSetKeyValue('windowOnloadResolve', resolve)\n" + '// \t\tresolve()\n' + '// \t}).then(res => {\n' + '\n' + '// \t}).finally(() => {\n' + '// \t\tprepareInjectJs()\n' + '// \t})\n' + '// }\n' + '\n' + '// for (let x in window) {\n' + '// \tif (x.startsWith("denk")) {\n' + '// \t\tconsole.info(x);\n' + '// \t}\n' + '// }\n' + '// // console.info(window)\n' + '// // ["monaco", "clearEditor", "createEditorFunc", "sendIpcMessage", "windowOnloadResolve", "prepareInjectJsResolve"]\n' + '// console.info(window.denkAllKeys());\n' + '\n' + '// const getOption = (filePath = "") => {\n' + '// \tlet myOption = {};\n' + '// \tif (filePath.endsWith(".js")) {\n' + '// \t\tmyOption.language = "javascript";\n' + '// \t}\n' + '\n' + '\n' + '// \tif (filePath.endsWith(".md")) {\n' + '// \t\tmyOption.theme = "myCoolTheme";\n' + '// \t\tmyOption.language = "markdown";\n' + '// \t}\n' + '\n' + '// \treturn {\n' + '// \t\tlanguage: "javascript",\n' + '// \t\t...myOption,\n' + '// \t};\n' + '// };\n' + '\n' + '// const getEditor = (filePath = "") => {\n' + '// \tconst id = "editor" + filePath;\n' + '// \tlet editor = window.denkGetKey(id);\n' + '// \tlet editorView = document.getElementById(id);\n' + '// \tif (!editor) {\n' + '// \t\tconst holder = document.getElementById("editor_container_holder");\n' + '// \t\tif (!holder) {\n' + '// \t\t\tthrow new Error("error");\n' + '// \t\t}\n' + '// \t\tif (!editorView) {\n' + '// \t\t\teditorView = document.createElement("div");\n' + '// \t\t\teditorView.style.width = "100%";\n' + '// \t\t\teditorView.style.height = "100%";\n' + '// \t\t\teditorView.id = id;\n' + '// \t\t\teditorView.className = "editor_view";\n' + '// \t\t\tholder.appendChild(editorView);\n' + '// \t\t}\n' + '// \t\tconst monaco = window.denkGetKey("monaco");\n' + '// \t\teditor = monaco.editor.create(editorView, getOption(filePath));\n' + '// \t\twindow.denkSetKeyValue(id, editor);\n' + '\n' + "// \t\tconst onEditorCreate = window.denkGetKey('onEditorCreate')\n" + "// \t\tif (onEditorCreate && typeof onEditorCreate === 'function') {\n" + '// \t\t\tonEditorCreate(editor)\n' + '// \t\t}\n' + '\n' + '// \t}\n' + '// \tfor (\n' + '// \t\tlet x = 0;\n' + '// \t\tx < document.getElementsByClassName("editor_view").length;\n' + '// \t\tx++\n' + '// \t) {\n' + '// \t\tdocument.getElementsByClassName("editor_view")[x].style.display =\n' + '// \t\t\t"none";\n' + '// \t}\n' + '// \teditorView.style.display = "";\n' + '\n' + '// \treturn editor;\n' + '// };\n' + '\n' + '// window.denkSetKeyValue("insertIntoEditor", (content, filePath) => {\n' + "// \tconsole.info('insertIntoEditor', content, filePath)\n" + '// \tgetEditor(filePath).setValue(content);\n' + '// });\n' + '\n' + '\n' + "// console.info('version 12')\n" + '\n' + '\n' + '// //# sourceURL=webpack://browser-esm-webpack/./index.js?';
const injectJsContent = 'console.info("DENKUI_EDITOR_INJECT start");\n' + '\n' + "window.denkSetKeyValue('getEditorByFilePath', (filePath) => {\n" + "    let editor = window.denkGetKey('editor' + filePath)\n" + "    console.info('getEditorByFilePath editor' , editor)\n" + '    if (!editor) {\n' + "        editor = window.denkGetKey('editor' + 'new')\n" + "        console.info('getEditorByFilePath editor from new' , editor)\n" + '    } \n' + '\n' + '    if (editor) {\n' + "        console.error('editor is null', window.denkAllKeys())\n" + '    } else {\n' + "        window.denkSetKeyValue('editor' + filePath, editor)\n" + '    }\n' + '    \n' + '    return editor\n' + '})\n' + '\n' + 'const getOption = (filePath = "") => {\n' + '    let myOption = {};\n' + '    if (filePath.endsWith(".js")) {\n' + '        myOption.language = "javascript";\n' + '    }\n' + '\n' + '\n' + '    if (filePath.endsWith(".md")) {\n' + '        myOption.theme = "myCoolTheme";\n' + '        myOption.language = "markdown";\n' + '    }\n' + '\n' + '    return {\n' + '        language: "javascript",\n' + '        ...myOption,\n' + '    };\n' + '};\n' + '\n' + 'const getEditor = (filePath = "") => {\n' + '    const id = "editor" + filePath;\n' + '    let editor = window.denkGetKey(id);\n' + '    let editorView = document.getElementById(id);\n' + '    if (!editor) {\n' + '        const holder = document.getElementById("editor_container_holder");\n' + '        if (!holder) {\n' + '            throw new Error("error");\n' + '        }\n' + '        if (!editorView) {\n' + '            editorView = document.createElement("div");\n' + '            editorView.style.width = "100%";\n' + '            editorView.style.height = "100%";\n' + '            editorView.id = id;\n' + '            editorView.className = "editor_view";\n' + '            holder.appendChild(editorView);\n' + '        }\n' + '        const monaco = window.denkGetKey("monaco");\n' + '        editor = monaco.editor.create(editorView, getOption(filePath));\n' + '        window.denkSetKeyValue(id, editor);\n' + '\n' + "        const onEditorCreate = window.denkGetKey('onEditorCreate')\n" + "        if (onEditorCreate && typeof onEditorCreate === 'function') {\n" + '            onEditorCreate(editor)\n' + '        }\n' + '\n' + '    }\n' + '    for (\n' + '        let x = 0;\n' + '        x < document.getElementsByClassName("editor_view").length;\n' + '        x++\n' + '    ) {\n' + '        document.getElementsByClassName("editor_view")[x].style.display =\n' + '            "none";\n' + '    }\n' + '    editorView.style.display = "";\n' + '\n' + '    return editor;\n' + '};\n' + '\n' + "denkSetKeyValue('getEditorFunc', getEditor)\n" + '\n' + 'window.denkSetKeyValue("insertIntoEditor", (content, filePath) => {\n' + "    console.info('insertIntoEditor', content, filePath)\n" + "    const targetEditor = window.denkGetKey('getEditorFunc')(filePath)\n" + '    if (targetEditor.getValue().trim() === "")\n' + '        targetEditor.setValue(content)\n' + '});\n' + '{\n' + '    const windowOnloadResolve = window.denkGetKey("windowOnloadResolve");\n' + '\n' + '    if (windowOnloadResolve) {\n' + '        windowOnloadResolve();\n' + '    }\n' + '\n' + '    const monaco = window.denkGetKey("monaco");\n' + '    // Register a new language\n' + '    monaco.languages.register({ id: "markdown" });\n' + '\n' + '    // Register a tokens provider for the language\n' + '    monaco.languages.setMonarchTokensProvider("markdown", {\n' + '        tokenizer: {\n' + '            root: [\n' + '                [/- .*?\\[DONE\\]/, "custom-done"],\n' + '                [/\\---/, "custom-title-bar"],\n' + '                [/^(title) ?: ?(.*)/, "custom-title-bar"],\n' + '                [/^(date) ?: ?(.*)/, "custom-title-bar"],\n' + '                [/^(tags) ?: ?(.*)/, "custom-title-bar"],\n' + '                [/^#{1,6} .*/, "custom-header"],\n' + '                [/- .*? /, "custom-list-item"],\n' + '                [/\\*\\*.*\\*\\*/, "custom-blod"],\n' + '                [/\\*.*\\*/, "custom-italic"],\n' + '                [/\\[error.*/, "custom-error"],\n' + '                [/\\d/, "custom-number"],\n' + '                [/\\[notice.*/, "custom-notice"],\n' + '                [/\\[info.*/, "custom-info"],\n' + '                [/\\[[a-zA-Z 0-9:]+\\]/, "custom-date"],\n' + '                [/const/, "custom-date"],\n' + '                [/".*?"/, "custom-date"],\n' + '\n' + '            ],\n' + '        },\n' + '    });\n' + '\n' + '    // Define a new theme that contains only rules that match this language\n' + '    monaco.editor.defineTheme("myCoolTheme", {\n' + '        base: "vs",\n' + '        inherit: true,\n' + '        rules: [\n' + '            { token: "custom-done", foreground: "aaaaaa" },\n' + '            { token: "custom-info", foreground: "808080" },\n' + '            { token: "custom-title-bar", foreground: "808080" },\n' + '            { token: "custom-header", foreground: "ffbcd4" },\n' + '            { token: "custom-list-item", foreground: "FFA500" },\n' + '            { token: "custom-title-bar", foreground: "808080" },\n' + '            { token: "custom-blod", foreground: "00aaff", fontStyle: "bold" },\n' + '            { token: "custom-italic", foreground: "ffaabb", fontStyle: "italic" },\n' + '            { token: "custom-error", foreground: "ff0000", fontStyle: "bold" },\n' + '            { token: "custom-number", foreground: "aa0000" },\n' + '            { token: "custom-notice", foreground: "FFA500" },\n' + '            { token: "custom-date", foreground: "008800" },\n' + '        ],\n' + '        colors: {\n' + '            "editor.foreground": "#000000",\n' + '        },\n' + '    });\n' + '\n' + '\n' + '    const initCodeLens = (editor) => {\n' + "        console.info('initCodeLens')\n" + '\n' + '        // monaco.languages.registerCodeLensProvider("javascript", codeLensProvider);\n' + '        // monaco.languages.registerCodeLensProvider("markdown", codeLensProvider);\n' + '    };\n' + '\n' + '\n' + '    const initCommands = (editor) => {\n' + '\n' + '        editor.addAction({\n' + '            // An unique identifier of the contributed action.\n' + "            id: 'save',\n" + '\n' + '            // A label of the action that will be presented to the user.\n' + "            label: 'save!!!',\n" + '\n' + '            // An optional array of keybindings for the action.\n' + '            keybindings: [\n' + '                monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS\n' + '            ],\n' + '\n' + '            // A precondition for this action.\n' + '            precondition: null,\n' + '\n' + '            // A rule to evaluate on top of the precondition in order to dispatch the keybindings.\n' + '            keybindingContext: null,\n' + '\n' + "            contextMenuGroupId: 'navigation',\n" + '\n' + '            contextMenuOrder: 1.5,\n' + '\n' + '            // Method that will be executed when the action is triggered.\n' + '            // @param editor The editor instance is passed in as a convenience\n' + '            run: function (ed) {\n' + "                window.denkGetKey('sendIpcMessage')( {\n" + "                    name: 'editorSave'\n" + '                })\n' + '            }\n' + '        });\n' + '\n' + '        editor.addAction({\n' + '            // An unique identifier of the contributed action.\n' + "            id: 'refresh',\n" + '\n' + '            // A label of the action that will be presented to the user.\n' + "            label: 'refresh',\n" + '\n' + '            // An optional array of keybindings for the action.\n' + '            keybindings: [\n' + '                monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyR\n' + '            ],\n' + '\n' + '            // A precondition for this action.\n' + '            precondition: null,\n' + '\n' + '            // A rule to evaluate on top of the precondition in order to dispatch the keybindings.\n' + '            keybindingContext: null,\n' + '\n' + "            contextMenuGroupId: 'navigation',\n" + '\n' + '            contextMenuOrder: 1.5,\n' + '\n' + '            // Method that will be executed when the action is triggered.\n' + '            // @param editor The editor instance is passed in as a convenience\n' + '            run: function (ed) {\n' + '               location.reload(false)\n' + '            }\n' + '        });\n' + '    }\n' + '\n' + "    window.denkSetKeyValue('onEditorCreate', (editor) => {\n" + "        console.info('onEditorCreate', editor)\n" + '        initCodeLens(editor)\n' + '        initCommands(editor)\n' + "        denkSetKeyValue('editornew', editor)\n" + '    })\n' + '\n' + '    // Register a completion item provider for the new language\n' + '    monaco.languages.registerCompletionItemProvider("markdown", {\n' + '        provideCompletionItems: () => {\n' + '            var suggestions = [];\n' + '\n' + '            const headerMaxLv = 6;\n' + '            let headerPrefix = "";\n' + '            for (let x = 1; x <= headerMaxLv; x++) {\n' + '                headerPrefix += "#";\n' + '                suggestions.push({\n' + '                    label: "_#" + x,\n' + '                    kind: monaco.languages.CompletionItemKind.Text,\n' + '                    insertText: headerPrefix + " ${1:header}",\n' + '                    insertTextRules:\n' + '                        monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,\n' + '                    documentation: "Header levele " + x,\n' + '                });\n' + '            }\n' + '            return { suggestions: suggestions };\n' + '        },\n' + '    });\n' + '\n' + '    const prepareInjectJsResolve = window.denkGetKey("prepareInjectJsResolve");\n' + '    if (prepareInjectJsResolve) {\n' + '        prepareInjectJsResolve();\n' + '    }\n' + '}';
const defaultJsContents = [];
const __default12 = {
    defaultJsContent,
    defaultJsContents,
    injectJsContent
};
class LocalHistoryService {
    basePath = '';
    MAX_STORAGE_LIMIT = 31457280;
    appContainerPath = Deno.env.get("HOME") + __default3.Dir.Spelator + 'lowbeelocalhistory';
    constructor(){}
    static Get(basePath) {
        const service = new LocalHistoryService();
        service.basePath = basePath;
        return service;
    }
    checkLocalHistorylimit() {
        let fileList = __default4.walkDirSync(this.appContainerPath);
        const statRes = fileList.filter((fileItem)=>{
            return fileItem.isFile;
        }).map((i)=>{
            const a = Deno.statSync(i.path);
            return {
                path: i.path,
                size: a.size,
                birthtime: a.birthtime
            };
        }).sort((a, b)=>{
            return a.birthtime - b.birthtime;
        });
        let size = 0;
        statRes.forEach((i)=>{
            size += i.size;
        });
        if (size > this.MAX_STORAGE_LIMIT) {
            __default4.unlinkFile(statRes[0].path);
            this.checkLocalHistorylimit();
        }
        return Promise.resolve(true);
    }
    _getFileKey(originPath) {
        let fileKey = originPath.replace(this.basePath, '');
        if (fileKey.startsWith('/')) {
            fileKey = fileKey.substring(1);
        }
        return fileKey;
    }
    _getTargetFolderPath(fileKey) {
        const curretnTargetFolderPath = this.appContainerPath + __default3.Dir.Spelator + fileKey;
        return curretnTargetFolderPath;
    }
    _makeSureDir(fileKey) {
        __default4.mkdirSync(this._getTargetFolderPath(fileKey), {
            recursive: true
        });
    }
    onReadLocalHistory(originPath) {
        let fileKey = this._getFileKey(originPath);
        this._makeSureDir(fileKey);
        return __default4.walkDirSync(this._getTargetFolderPath(fileKey)).sort((a, b)=>{
            return a.path - b.path;
        });
    }
    onWriteFile(originPath, content) {
        __default1.info('LocalHistoryService', originPath, this.basePath, this.appContainerPath);
        let fileKey = this._getFileKey(originPath);
        this._makeSureDir(fileKey);
        __default4.writeFileSync(this._getTargetFolderPath(fileKey) + __default3.Dir.Spelator + new Date().getTime(), content);
        this.checkLocalHistorylimit();
        return Promise.resolve(true);
    }
}
class KfTodoController {
    ipc = null;
    hasFirstConnect = false;
    static KFTODO_CONFIG_MD_PATH = __default3.homePath() + __default3.Dir.Spelator + ".denkui" + __default3.Dir.Spelator + ".config.md";
    rssController = new RssController();
    config = {
        basePath: "."
    };
    async start() {
        let res = await __default5.get({
            key: "GLOBAL_PORT"
        });
        let iport = 8673;
        try {
            iport = Number.parseInt(res.data);
        } catch (err) {
            __default1.error("KfTodoController", err);
        }
        __default1.info("KfTodoController port ", res.data, iport);
        this.ipc = new AsyncIpcController(iport || 8673);
        const onMessageHandler = (message)=>{
            this.onMessage(message);
        };
        const onFirstConnect = (message)=>{
            this.hasFirstConnect = false;
        };
        this.ipc.addOnConnectCallback(onFirstConnect);
        this.ipc.addCallback(onMessageHandler);
        setInterval(()=>{
            this.heart();
        }, 2000);
        __default7.init(this.send);
        this.rssController.initResponseFunc((data)=>{
            data.isResponse = true;
            this.send(data);
        });
    }
    heart() {
        !this.hasFirstConnect && this.ipc?.send(JSON.stringify({
            name: "heart",
            data: "KfTodoController " + !this.hasFirstConnect
        }));
    }
    send(event) {
        this.ipc?.send(JSON.stringify(event));
    }
    async initData() {
        __default1.info("KfTodoController", "initData");
        const listDataRes = await __default5.get({
            key: "listData"
        });
        __default1.info("KfTodoController initData getlistdata");
        const confgPath = KfTodoController.KFTODO_CONFIG_MD_PATH;
        try {
            if (!listDataRes.data || !__default4.statSync(confgPath).isExist) {
                __default1.info("KfTodoController initData getlistdata", listDataRes.data?.length);
                const configTitle = "KfTodoConfig";
                const configTags = [
                    "_KfTodoConfig"
                ];
                let item = {
                    "title": configTitle,
                    "date": new Date().toDateString(),
                    "dateMs": new Date().getTime(),
                    "path": confgPath,
                    "tags": configTags
                };
                if (!__default4.statSync(confgPath).isExist) {
                    const content = BlogTextHelper.GenerateEmptyText(configTitle, configTags, JSON.stringify({
                        basePath: "."
                    }, null, 2));
                    __default4.mkdirSync(__default3.getDirPath(confgPath), {
                        recursive: true
                    });
                    __default4.writeFileSync(confgPath, content);
                } else {
                    const currentConfigContent = __default4.readFileSync(confgPath);
                    try {
                        this.config = JSON.parse(BlogTextHelper.GetContentFromText(currentConfigContent));
                    } catch (err) {
                        this.send({
                            name: "system.toast",
                            data: {
                                error: `${err}`
                            }
                        });
                    }
                    item = __default6.handleFile(currentConfigContent, confgPath);
                }
                listDataRes.data = {
                    headerInfos: [
                        item
                    ]
                };
                await __default5.set({
                    key: "listData",
                    value: listDataRes.data
                });
            } else {
                const currentConfigContent1 = __default4.readFileSync(confgPath);
                this.config = JSON.parse(BlogTextHelper.GetContentFromText(currentConfigContent1));
            }
        } catch (err1) {
            __default1.info(err1);
            this.send({
                name: "toast",
                data: {
                    error: `${err1}`
                }
            });
        }
        this.initByConfig();
        const lastReadPathRes = await __default5.get({
            key: "lastReadPath"
        });
        if (lastReadPathRes.data) {
            this.send({
                name: "notifyRead",
                data: lastReadPathRes.data
            });
        }
    }
    async getMdHeaderInfoByPath(filePath, content) {
        const listDataRes = await __default5.get({
            key: "listData"
        });
        const hitItems = listDataRes.data.headerInfos.filter((item)=>{
            return item.path == filePath;
        });
        let item = {};
        if (hitItems.length === 0) {
            item = {
                "title": content.substring(0, 20),
                "date": new Date().toDateString(),
                "dateMs": new Date().getTime(),
                "path": filePath,
                "tags": []
            };
            listDataRes.data.headerInfos && listDataRes.data.headerInfos.push(item);
        } else {
            item = hitItems[0];
        }
        return item;
    }
    async getOtherHeaderInfos() {
        const listDataRes = await __default5.get({
            key: "listData"
        });
        console.info("kfdbeug", listDataRes);
        return listDataRes ? listDataRes.data.headerInfos.filter((header)=>{
            return header.type != undefined;
        }) : [];
    }
    generateInjectJsFile(resourcePath) {
        const editorInjectJsPath = resourcePath + __default3.Dir.Spelator + 'manoco-editor' + __default3.Dir.Spelator + 'inject';
        const res = __default4.walkDirSync(editorInjectJsPath).map((i)=>{
            return i.path;
        });
        __default1.info("KfTodoController generateInjectJsFile", res);
        return res;
    }
    async initInjectJsFile() {
        const editorInjectJsPath = this.config["editorInjectJsPath"];
        if (typeof editorInjectJsPath === 'string') {
            if (!editorInjectJsPath || __default4.isEmptyFile(editorInjectJsPath)) {
                __default4.writeFileSync(editorInjectJsPath, __default12.injectJsContent);
            }
        }
    }
    async initDefaultJsFile() {
        const basePath = this.config["basePath"];
        const defaultJsPath = basePath + __default3.Dir.Spelator + "default.js";
        if (__default4.isEmptyFile(defaultJsPath)) {
            __default4.writeFileSync(defaultJsPath, __default12.defaultJsContent);
        }
    }
    async initByConfig() {
        const files = __default4.walkDirSync(this.config.basePath);
        const denkuiblogFiles = files.filter((value)=>{
            const ext = __default8.getFileExtByType("denkuiblog", this.config);
            return value.name.endsWith(ext);
        });
        const infos = denkuiblogFiles.map((i)=>{
            __default1.info("KfTodoController ", i);
            return __default6.handleFile(__default4.readFileSync(i.path), i.path);
        }).filter((i)=>{
            return i.title;
        });
        const scriptFiles = files.filter((value)=>{
            return value.name.endsWith(__default8.getFileExtByType("script", this.config));
        });
        __default1.info("KfTodoController scriptFiles", scriptFiles);
        scriptFiles.forEach((scriptFile)=>{
            infos.push({
                path: scriptFile.path,
                title: scriptFile.name,
                date: "SCRIPT",
                tags: [
                    "_DENKUISCRIPT"
                ]
            });
        });
        __default1.info("KfTodoController ", infos);
        const item = await this.getMdHeaderInfoByPath(KfTodoController.KFTODO_CONFIG_MD_PATH, "DENKUI_CONFIG");
        const resData = {
            headerInfos: infos.concat([
                item
            ])
        };
        const otherDatas = await this.getOtherHeaderInfos();
        resData.headerInfos = resData.headerInfos.concat(otherDatas);
        await __default5.set({
            key: "listData",
            value: resData
        });
        this.send({
            name: "initData",
            data: resData
        });
    }
    async handleInvoke(ipcData) {
        const { invokeName , data: invokeData  } = ipcData.data;
        __default1.info("handleInvoke invokeName:", invokeName);
        if (invokeName === "readFile") {
            const path = invokeData;
            const content = __default4.readFileSync(path);
            ipcData.data = {
                content,
                path: invokeData
            };
            this.ipc?.response(ipcData);
            await __default5.set({
                key: "lastReadPath",
                value: path
            });
        }
        if (invokeName === "getConfig") {
            ipcData.data = this.config;
            this.ipc?.response(ipcData);
        }
        if (invokeName === "saveConfig") {
            __default1.info("on saveConfig", ipcData.data.data);
            let cacheConfig = this.config;
            for(let x in ipcData.data.data){
                cacheConfig[x] = ipcData.data.data[x];
            }
            const content1 = __default4.readFileSync(KfTodoController.KFTODO_CONFIG_MD_PATH);
            let headerContent = BlogTextHelper.GetHeaderInfoFromText(content1);
            if (headerContent === null) {
                headerContent = '';
            }
            this.config["editorInjectJsPath"] = this.generateInjectJsFile(cacheConfig['resourcePath']);
            const newContent = headerContent + JSON.stringify(cacheConfig, null, 2);
            __default4.mkdirSync(__default3.getDirPath(KfTodoController.KFTODO_CONFIG_MD_PATH), {
                recursive: true
            });
            __default4.writeFileSync(KfTodoController.KFTODO_CONFIG_MD_PATH, newContent);
            this.config = cacheConfig;
            this.initByConfig();
        }
        if (invokeName === 'readLocalHistory') {
            const { path: path1  } = invokeData;
            const res = LocalHistoryService.Get(this.config.basePath).onReadLocalHistory(path1);
            ipcData.data = {
                history: res
            };
            this.ipc?.response(ipcData);
        }
        if (invokeName === "writeFile") {
            const { content: content2 , path: path2  } = invokeData;
            __default4.mkdirSync(__default3.getDirPath(path2), {
                recursive: true
            });
            __default4.writeFileSync(path2, content2);
            LocalHistoryService.Get(this.config.basePath).onWriteFile(path2, content2).then((res)=>{});
            __default1.info("handleInvoke writeFile path:", path2);
            if (path2.endsWith(__default8.getFileExtByType("script", this.config))) {
                ipcData.msg = `${ipcData.data.invokeName} success`;
                this.ipc?.response(ipcData);
            } else {
                const listDataRes = await __default5.get({
                    key: "listData"
                });
                let item = await this.getMdHeaderInfoByPath(path2, content2);
                __default1.info("handleInvoke writeFile path compare to", KfTodoController.KFTODO_CONFIG_MD_PATH);
                if (path2 === KfTodoController.KFTODO_CONFIG_MD_PATH || path2 === "./.denkui/.config.md") {
                    try {
                        const configContent = BlogTextHelper.GetContentFromText(content2).trim();
                        __default1.info("KfTodoController ", configContent);
                        this.config = JSON.parse(configContent);
                        this.initByConfig();
                        ipcData.msg = `initData by config success`;
                        this.ipc?.response(ipcData);
                    } catch (err) {
                        __default1.info("KfTodoController", err);
                        ipcData.data = {
                            error: "error: " + err
                        };
                        this.ipc?.response(ipcData);
                    }
                } else {
                    try {
                        let info = __default6.handleFile(content2, path2);
                        item.title = info.title;
                        item.date = info.date;
                        item.path = info.path;
                        item.tags = info.tags;
                        ipcData.msg = `${ipcData.data.invokeName} success`;
                    } catch (err1) {
                        ipcData.data = {
                            error: "error: " + err1
                        };
                        this.ipc?.response(ipcData);
                        return;
                    }
                    await __default5.set({
                        key: "listData",
                        value: listDataRes.data
                    });
                    this.ipc?.response(ipcData);
                }
            }
        }
        if (invokeName === "deleteItem") {
            const { path: path3  } = invokeData;
            __default1.info("KfTodoController try deleteItem", path3);
            if (!path3.startsWith('http')) {
                await __default4.unlinkFile(path3);
            }
            const listDataRes1 = await __default5.get({
                key: "listData"
            });
            const hitItems = listDataRes1.data.headerInfos.filter((item)=>{
                if (item.path == path3) {
                    __default1.info("KfTodoController deleteItem", path3);
                }
                return item.path != path3;
            });
            listDataRes1.data.headerInfos = hitItems;
            await __default5.set({
                key: "listData",
                value: listDataRes1.data
            });
            this.ipc?.response(ipcData);
        }
        if (invokeName === "getNewBlogTemplate") {
            const content3 = BlogTextHelper.GenerateEmptyText();
            ipcData.data = {
                content: content3,
                path: this.config.basePath
            };
            this.ipc?.response(ipcData);
        }
        if (invokeName === "initData") {
            const { path: path4  } = invokeData;
            const files = __default4.walkDirSync(path4);
            const denkuiblogFiles = files.filter((value)=>{
                const ext = __default8.getFileExtByType("denkuiblog", this.config);
                return value.name.endsWith(ext);
            });
            let headerInfos = denkuiblogFiles.map((value)=>{
                return __default6.handleFile(__default4.readFileSync(value.path), value.path);
            });
            const scriptFiles = files.filter((value)=>{
                return value.name.endsWith(__default8.getFileExtByType("script", this.config));
            });
            __default1.info("KfTodoController scriptFiles", scriptFiles);
            scriptFiles.forEach((scriptFile)=>{
                headerInfos.push({
                    path: scriptFile.path,
                    title: scriptFile.name,
                    date: "SCRIPT",
                    tags: [
                        "_DENKUISCRIPT"
                    ]
                });
            });
            ipcData.data = {
                headerInfos
            };
            await __default5.set({
                key: "listData",
                value: ipcData.data
            });
            this.ipc?.response(ipcData);
        }
        this.rssController.tryHandleInvoke(ipcData);
    }
    onMessage(message) {
        __default1.info("KfTodoController onMessage", message);
        if (!this.hasFirstConnect) {
            this.hasFirstConnect = true;
        }
        try {
            const event = JSON.parse(message);
            __default1.info("KfTodoController onMessage event", event);
            if (event.name === "onFirstConnect") {
                this.initData().catch((reason)=>{
                    event.data = {
                        error: reason + ""
                    };
                    this.ipc?.response(event);
                });
            }
            if (event.name === "invoke") {
                this.handleInvoke(event).catch((reason)=>{
                    event.data = {
                        error: reason + ""
                    };
                    this.ipc?.response(event);
                });
            }
        } catch (err) {
            __default1.info("KfTodoController onMessage err", err);
        }
    }
}
let homePath1 = '';
const startHttpServer = async ()=>{
    const server = Deno.listen({
        port: 10825
    });
    console.log("File server running on http://localhost:10825/");
    for await (const conn of server){
        handleHttp(conn).catch(console.error);
    }
    async function handleHttp(conn) {
        const httpConn = Deno.serveHttp(conn);
        for await (const requestEvent of httpConn){
            const url = new URL(requestEvent.request.url);
            const filepath = decodeURIComponent(url.pathname);
            console.info('requestEvent.request.url', requestEvent.request.url);
            if (homePath1 == '') {
                try {
                    homePath1 = requestEvent.request.url.split('home=')[1];
                } catch  {}
            }
            let file;
            const targetPath = homePath1 === '' ? __default3.homePath() + __default3.Dir.Spelator + 'editor' : homePath1;
            try {
                file = await Deno.open(targetPath + filepath, {
                    read: true
                });
            } catch  {
                const notFoundResponse = new Response("404 Not Found: " + targetPath + filepath, {
                    status: 404
                });
                await requestEvent.respondWith(notFoundResponse);
                return;
            }
            const readableStream = file.readable;
            const response = new Response(readableStream);
            await requestEvent.respondWith(response);
        }
    }
};
const __default13 = {
    startHttpServer
};
let args = __default.GetArgs();
let isLcOpen = false;
let global = {
    port: 8673
};
args.forEach((val)=>{
    const portPrefix = '--port=';
    if (val.startsWith(portPrefix)) {
        let port = val.substring(portPrefix.length);
        __default5.set({
            key: 'GLOBAL_PORT',
            value: port
        });
        global.port = Number.parseInt(port);
    }
});
const kf = new KfTodoController();
if (!isLcOpen) {
    kf.start();
}
__default13.startHttpServer();
