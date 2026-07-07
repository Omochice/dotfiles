import { Buffer } from "node:buffer";
import net from "node:net";

const SOCKET_PATH = `/tmp/yabai_${Deno.env.get("USER")}.socket`;

const FAILURE_MESSAGE = 0x07;

function encodeMessage(args: readonly string[]): Uint8Array {
  const encoder = new TextEncoder();
  const body: number[] = [];
  for (const arg of args) {
    body.push(...encoder.encode(arg), 0);
  }
  // A trailing null terminates the argument list.
  body.push(0);
  const payload = Uint8Array.from(body);

  // yabai frames each message with a 4-byte little-endian length prefix.
  const frame = new Uint8Array(4 + payload.length);
  new DataView(frame.buffer).setInt32(0, payload.length, true);
  frame.set(payload, 4);
  return frame;
}

/**
 * Send a message to the running yabai daemon.
 *
 * @param args the tokens that follow `yabai -m`.
 * @throws {Error} when yabai reports the command as failed.
 */
export function message(args: readonly string[]): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    // `node:net` is used instead of `Deno.connect({ transport: "unix" })`
    // because the latter rejects while decoding the peer address on macOS.
    const socket = net.createConnection(SOCKET_PATH);
    socket.on("connect", () => {
      socket.write(encodeMessage(args));
      // Half-close the write side so the daemon observes end-of-message.
      socket.end();
    });
    socket.on("data", (chunk: Buffer) => chunks.push(chunk));
    socket.on("error", reject);
    socket.on("end", () => {
      const response = Buffer.concat(chunks);
      if (response[0] === FAILURE_MESSAGE) {
        reject(new Error(response.subarray(1).toString("utf8")));
        return;
      }
      resolve(response.toString("utf8"));
    });
  });
}

/**
 * Send a message whose response is JSON and resolve with the parsed value.
 */
export async function messageJson<T = unknown>(
  args: readonly string[],
): Promise<T> {
  return JSON.parse(await message(args)) as T;
}
