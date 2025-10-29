module tamashi::image_series;

use std::string::String;
use sui::derived_object::claim;
use sui::vec_set;
use tamashi::admin::AdminCap;
use tamashi::constants::{collection_size, default_image_name, default_image_quilt_id};

//=== Structs ===

public struct IMAGE_SERIES() has drop;

public struct ImageSeries has key {
    id: UID,
    name: String,
    quilt_id: String,
    eligible_tamashi: vector<u8>,
}

public struct ImageSeriesKey(String) has copy, drop, store;

public struct ImageSeriesRegistry has key {
    id: UID,
}

//=== Errors ===

const EIneligibleTamashi: u64 = 0;

//=== Init Function ===

fun init(_otw: IMAGE_SERIES, ctx: &mut TxContext) {
    let mut image_series_registry = ImageSeriesRegistry {
        id: object::new(ctx),
    };

    let image_series = new_impl(
        default_image_name!().to_string(),
        default_image_quilt_id!().to_string(),
        vector::tabulate!(collection_size!() as u64, |idx| idx as u8 + 1),
        &mut image_series_registry,
    );

    transfer::freeze_object(image_series);
    transfer::share_object(image_series_registry);
}

//=== Public Functions ===

public fun new(
    _: &AdminCap,
    name: String,
    quilt_id: String,
    eligible_tamashi: vector<u8>,
    registry: &mut ImageSeriesRegistry,
) {
    let image_series = new_impl(name, quilt_id, eligible_tamashi, registry);
    transfer::freeze_object(image_series);
}

//=== Public View Functions ===

public fun id(self: &ImageSeries): ID {
    self.id.to_inner()
}

public fun name(self: &ImageSeries): String {
    self.name
}

public fun quilt_id(self: &ImageSeries): String {
    self.quilt_id
}

public fun eligible_tamashi(self: &ImageSeries): &vector<u8> {
    &self.eligible_tamashi
}

//=== Assert Functions ===

public(package) fun assert_is_eligible_tamashi(self: &ImageSeries, number: u8) {
    assert!(self.eligible_tamashi().contains(&number), EIneligibleTamashi);
}

//=== Private Functions ===

fun new_impl(
    name: String,
    quilt_id: String,
    eligible_tamashi: vector<u8>,
    registry: &mut ImageSeriesRegistry,
): ImageSeries {
    ImageSeries {
        id: claim(&mut registry.id, ImageSeriesKey(name)),
        name,
        quilt_id,
        eligible_tamashi: vec_set::from_keys(eligible_tamashi).into_keys(),
    }
}
