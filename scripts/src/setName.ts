import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { cleanEnv, str } from "envalid";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui/utils";

const env = cleanEnv(process.env, {
  SUI_RPC_URL: str(),
  SUI_PRIVATE_KEY: str(),
  PACKAGE_ID: str(),
  TAMASHI_ID: str(),
  NAME: str(),
});

const client = new SuiClient({
  url: env.SUI_RPC_URL,
});

const keypair = Ed25519Keypair.fromSecretKey(env.SUI_PRIVATE_KEY);
console.log(keypair.getPublicKey().toSuiAddress());

const tx = new Transaction();
tx.moveCall({
  target: `${env.PACKAGE_ID}::tamashi::set_name`,
  arguments: [
    tx.object(env.TAMASHI_ID),
    tx.pure.string(env.NAME),
    tx.object(SUI_CLOCK_OBJECT_ID),
  ],
});
const result = await client.signAndExecuteTransaction({
  signer: keypair,
  transaction: tx,
});
await client.waitForTransaction({ digest: result.digest });
console.log(result.digest);
