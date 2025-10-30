import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { cleanEnv, str } from "envalid";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";

const env = cleanEnv(process.env, {
  SUI_RPC_URL: str(),
  SUI_PRIVATE_KEY: str(),
  PACKAGE_ID: str(),
  ADMIN_CAP_ID: str(),
  NAME: str(),
  QUILT_ID: str(),
  ELIGIBLE_TAMASHI: str(),
  IMAGE_SERIES_REGISTRY_ID: str(),
});

const client = new SuiClient({
  url: env.SUI_RPC_URL,
});

const keypair = Ed25519Keypair.fromSecretKey(env.SUI_PRIVATE_KEY);
console.log(keypair.getPublicKey().toSuiAddress());

const eligibleTamashi: number[] = Array.from(
  new Set(
    env.ELIGIBLE_TAMASHI.split(",")
      .map(Number)
      .filter((n) => Number.isInteger(n) && n >= 1 && n <= 100)
  )
);

const tx = new Transaction();
tx.moveCall({
  target: `${env.PACKAGE_ID}::image_series::new`,
  arguments: [
    tx.object(env.ADMIN_CAP_ID),
    tx.pure.string(env.NAME),
    tx.pure.string(env.QUILT_ID),
    tx.pure.vector("u8", eligibleTamashi),
    tx.object(env.IMAGE_SERIES_REGISTRY_ID),
  ],
});
const result = await client.signAndExecuteTransaction({
  signer: keypair,
  transaction: tx,
});
await client.waitForTransaction({ digest: result.digest });
console.log(result.digest);
