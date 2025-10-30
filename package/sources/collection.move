// SPDX-License-Identifier: CC-BY-NC-4.0
// © 2025 Studio Mirai. Non-commercial use only.
module tamashi::collection;

use std::string::String;

public struct COLLECTION() has drop;

//=== Structs ===

public struct Collection has key {
    id: UID,
    name: String,
    description: String,
    creator: String,
    supply: u8,
    symbol: String,
    image_url: String,
    website_url: String,
}

//=== Constants ===

const COLLECTION_NAME: vector<u8> = b"Tamashi";
const COLLECTION_DESCRIPTION: vector<u8> =
    b"A collection of 100 uniquely created individuals looking to rebuild the soul of their long-lost world in their new capital city of Nozomi.";
const COLLECTION_CREATOR: vector<u8> = b"@studiomirai";
const COLLECTION_SUPPLY: u8 = 100;
const COLLECTION_SYMBOL: vector<u8> = b"TAMASHI";
const IMAGE_URL: vector<u8> = b"https://nozomi.world/images/collections/tamashi.webp";
const WEBSITE_URL: vector<u8> = b"https://nozomi.world/collections/tamashi";

fun init(_otw: COLLECTION, ctx: &mut TxContext) {
    let collection = Collection {
        id: object::new(ctx),
        name: COLLECTION_NAME.to_string(),
        description: COLLECTION_DESCRIPTION.to_string(),
        creator: COLLECTION_CREATOR.to_string(),
        supply: COLLECTION_SUPPLY,
        symbol: COLLECTION_SYMBOL.to_string(),
        image_url: IMAGE_URL.to_string(),
        website_url: WEBSITE_URL.to_string(),
    };
    transfer::freeze_object(collection);
}
