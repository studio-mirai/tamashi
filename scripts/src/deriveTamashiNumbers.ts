import { cleanEnv, str } from "envalid";
import { bcs } from "@mysten/bcs";
import { deriveObjectID } from "@mysten/sui/utils";

const env = cleanEnv(process.env, {
  PACKAGE_ID: str(),
  TAMASHI_REGISTRY_ID: str(),
});

for (let i = 1; i <= 100; i++) {
  const tamashiId = deriveObjectID(
    env.TAMASHI_REGISTRY_ID,
    "u8",
    bcs.u8().serialize(i).toBytes()
  );
  console.log(tamashiId);
}
