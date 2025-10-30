// SPDX-License-Identifier: CC-BY-NC-4.0
// © 2025 Studio Mirai. Non-commercial use only.

module tamashi::tamashi;

use std::string::String;
use sui::clock::Clock;
use sui::derived_object::claim;
use sui::display;
use sui::package;
use sui::transfer::Receiving;
use tamashi::constants::{
    collection_size,
    descriptions,
    default_image_name,
    default_image_quilt_id,
    migration_addresses
};
use tamashi::image_series::ImageSeries;

//=== Structs ===

public struct TAMASHI() has drop;

public struct Tamashi has key, store {
    id: UID,
    state: TamashiState,
    number: u8,
    name: String,
    description: String,
    image_name: String,
    image_quilt_id: String,
    migrated_by: address,
}

public struct TamashiRegistry has key {
    id: UID,
}

public enum TamashiState has copy, drop, store {
    Unnamed,
    // (namer_address, naming_timestamp)
    Named(address, u64),
}

//=== Constants ===

const DISPLAY_KEYS: vector<vector<u8>> = vector[
    b"number",
    b"name",
    b"description",
    b"image_name",
    b"image_uri",
    b"image_url",
    b"migrated_by",
];
const DISPLAY_VALUES: vector<vector<u8>> = vector[
    b"{number}",
    b"{name}",
    b"{description}",
    b"{image_name}",
    b"{image_quilt_id}/{number}.webp",
    b"https://aggregator.mainnet.walrus.mirai.cloud/v1/blobs/by-quilt-id/{image_quilt_id}/{number}.webp",
    b"{migrated_by}",
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

    let mut descriptions = descriptions!();
    assert!(descriptions.length() == collection_size!() as u64, EInvalidDescriptionsCount);
    let mut migration_addresses = migration_addresses!();
    assert!(migration_addresses.length() == collection_size!() as u64, EInvalidAddressesCount);

    descriptions.reverse();
    migration_addresses.reverse();

    // Create the TamashiRegistry to use as a parent for deriving addresses.
    let mut registry = TamashiRegistry {
        id: object::new(ctx),
    };

    let name_base = b"Tamashi #".to_string();
    let image_name = default_image_name!().to_string();
    let image_quilt_id = default_image_quilt_id!().to_string();

    let sender = ctx.sender();

    collection_size!().do!(|idx| {
        let number = idx + 1;
        // Build the name string.
        let mut name = name_base;
        name.append(number.to_string());
        let migrated_by = migration_addresses.pop_back();
        // Create and transfer the Tamashi.
        let tamashi = Tamashi {
            id: claim(&mut registry.id, number),
            state: TamashiState::Unnamed,
            number,
            name,
            description: descriptions.pop_back(),
            image_name,
            image_quilt_id,
            migrated_by,
        };
        transfer::public_transfer(tamashi, migrated_by);
    });

    transfer::public_transfer(display, sender);

    transfer::freeze_object(registry);

    // Destroy the Publisher, yikes!
    publisher.burn();
}

//=== Public Functions ===

public fun set_image_series(self: &mut Tamashi, image_series: &ImageSeries) {
    image_series.assert_is_eligible_tamashi(self.number);
    self.image_name = image_series.name();
    self.image_quilt_id = image_series.quilt_id();
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

public fun receive<T: key + store>(self: &mut Tamashi, obj_to_receive: Receiving<T>): T {
    transfer::public_receive(&mut self.id, obj_to_receive)
}

public fun destroy(self: Tamashi) {
    let Tamashi { id, .. } = self;
    id.delete();
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

public fun migrated_by(self: &Tamashi): address {
    self.migrated_by
}
