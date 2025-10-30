import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { cleanEnv, str } from "envalid";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { deriveObjectID } from "@mysten/sui/utils";
import { bcs } from "@mysten/bcs";

const env = cleanEnv(process.env, {
  SUI_RPC_URL: str(),
  SUI_PRIVATE_KEY: str(),
  PACKAGE_ID: str(),
  TAMASHI_ID: str(),
  IMAGE_SERIES_NAME: str(),
  IMAGE_SERIES_REGISTRY_ID: str(),
});

const client = new SuiClient({
  url: env.SUI_RPC_URL,
});

const keypair = Ed25519Keypair.fromSecretKey(env.SUI_PRIVATE_KEY);
console.log(`Sui Adddress: ${keypair.getPublicKey().toSuiAddress()}`);

const imageSeriesKeyTypeTag = `${env.PACKAGE_ID}::image_series::ImageSeriesKey`;
const imageSeriesKeyType = bcs.struct("ImageSeriesKey", {
  pos0: bcs.string(),
});

const imageSeriesID = deriveObjectID(
  env.IMAGE_SERIES_REGISTRY_ID,
  imageSeriesKeyTypeTag,
  imageSeriesKeyType.serialize({ pos0: env.IMAGE_SERIES_NAME }).toBytes()
);

const tx = new Transaction();
tx.moveCall({
  target: `${env.PACKAGE_ID}::tamashi::set_image_series`,
  arguments: [tx.object(env.TAMASHI_ID), tx.object(imageSeriesID)],
});
const result = await client.signAndExecuteTransaction({
  signer: keypair,
  transaction: tx,
});
await client.waitForTransaction({ digest: result.digest });
console.log(result.digest);
