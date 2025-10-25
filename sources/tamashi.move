module tamashi::tamashi;

use std::string::String;
use sui::clock::Clock;
use sui::derived_object::claim;
use sui::display;
use sui::package;
use tamashi::constants::{addresses, descriptions};
use tamashi::image_variant::ImageVariant;

//=== Structs ===

public struct TAMASHI() has drop;

public struct Tamashi has key, store {
    id: UID,
    state: TamashiState,
    number: u8,
    name: String,
    description: String,
    image_quilt_id: String,
    image_name: String,
    migrator: address,
}

public struct TamashiRegistry has key {
    id: UID,
}

public enum TamashiState has copy, drop, store {
    Unnamed,
    Named(address, u64),
}

//=== Constants ===

const COLLECTION_SIZE: u8 = 100;
const DEFAULT_IMAGE_QUILT_ID: vector<u8> = b"hAKUrbgRtn63UDGulNOWIGicUgt_kwkAkwCjcvYhxlY";
const DEFAULT_IMAGE_NAME: vector<u8> = b"ORIGINAL";
const DISPLAY_KEYS: vector<vector<u8>> = vector[
    b"number",
    b"name",
    b"description",
    b"image_name",
    b"image_uri",
    b"image_url",
    b"migrator",
];
const DISPLAY_VALUES: vector<vector<u8>> = vector[
    b"{number}",
    b"{name}",
    b"{description}",
    b"{image_name}",
    b"{image_quilt_id}/{number}.webp",
    b"https://aggregator.mainnet.walrus.mirai.cloud/v1/blobs/by-quilt-id/{image_quilt_id}/{number}.webp",
    b"{migrator}",
];

//=== Errors ===

const EAlreadyNamed: u64 = 0;
const EInvalidAddressesCount: u64 = 1;
const EInvalidDescriptionsCount: u64 = 2;

//=== Init Function ===

fun init(otw: TAMASHI, ctx: &mut TxContext) {
    // Claim the Publisher.
    let publisher = package::claim(otw, ctx);

    // Create and configure Display for the Tamashi type.
    let mut display = display::new<Tamashi>(&publisher, ctx);
    display.add_multiple(
        DISPLAY_KEYS.map!(|display_key| display_key.to_string()),
        DISPLAY_VALUES.map!(|display_value| display_value.to_string()),
    );
    display.update_version();

    let mut addresses = addresses!();
    assert!(addresses.length() == COLLECTION_SIZE as u64, EInvalidAddressesCount);
    let mut descriptions = descriptions!();
    assert!(descriptions.length() == COLLECTION_SIZE as u64, EInvalidDescriptionsCount);

    addresses.reverse();
    descriptions.reverse();

    // Create the TamashiRegistry to use as a parent for deriving addresses.
    let mut registry = TamashiRegistry {
        id: object::new(ctx),
    };

    let name_base = b"Tamashi #".to_string();
    let image_name = DEFAULT_IMAGE_NAME.to_string();
    let image_quilt_id = DEFAULT_IMAGE_QUILT_ID.to_string();

    let sender = ctx.sender();

    COLLECTION_SIZE.do!(|idx| {
        let number = idx + 1;
        // Build the name string.
        let mut name = name_base;
        name.append(number.to_string());
        let migrator = addresses.pop_back();
        // Create and transfer the Tamashi.
        let tamashi = Tamashi {
            id: claim(&mut registry.id, number),
            state: TamashiState::Unnamed,
            number,
            name,
            description: descriptions.pop_back(),
            image_name,
            image_quilt_id,
            migrator,
        };
        transfer::public_transfer(tamashi, migrator);
    });

    transfer::public_transfer(publisher, sender);
    transfer::public_transfer(display, sender);

    transfer::share_object(registry);
}

//=== Public Functions ===

public fun set_image_variant(self: &mut Tamashi, image_variant: &ImageVariant) {
    self.image_name = image_variant.name();
    self.image_quilt_id = image_variant.quilt_id();
}

public fun set_name(self: &mut Tamashi, name: String, clock: &Clock, ctx: &mut TxContext) {
    match (self.state) {
        TamashiState::Unnamed => {
            self.name = name;
            self.state = TamashiState::Named(ctx.sender(), clock.timestamp_ms());
        },
        TamashiState::Named(..) => abort EAlreadyNamed,
    }
}

//=== Public View Functions ===

public fun id(self: &Tamashi): ID {
    self.id.to_inner()
}

public fun number(self: &Tamashi): u8 {
    self.number
}

public fun name(self: &Tamashi): String {
    self.name
}

public fun description(self: &Tamashi): String {
    self.description
}

public fun image_name(self: &Tamashi): String {
    self.image_name
}

public fun image_quilt_id(self: &Tamashi): String {
    self.image_quilt_id
}

public fun migrator(self: &Tamashi): address {
    self.migrator
}
