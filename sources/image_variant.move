module tamashi::image_variant;

use std::string::String;
use sui::derived_object::claim;
use tamashi::admin::AdminCap;

//=== Structs ===

public struct IMAGE_VARIANT() has drop;

public struct ImageVariant has key {
    id: UID,
    name: String,
    quilt_id: String,
}

public struct ImageVariantKey(String, String) has copy, drop, store;

public struct ImageVariantRegistry has key {
    id: UID,
}

//=== Init Function ===

fun init(_otw: IMAGE_VARIANT, ctx: &mut TxContext) {
    let image_variant_registry = ImageVariantRegistry {
        id: object::new(ctx),
    };
    transfer::share_object(image_variant_registry);
}

//=== Public Functions ===

public fun new(_: &AdminCap, name: String, quilt_id: String, registry: &mut ImageVariantRegistry) {
    let image_variant = ImageVariant {
        id: claim(&mut registry.id, ImageVariantKey(name, quilt_id)),
        name,
        quilt_id,
    };
    transfer::freeze_object(image_variant);
}

//=== Public View Functions ===

public fun id(self: &ImageVariant): ID {
    self.id.to_inner()
}

public fun name(self: &ImageVariant): String {
    self.name
}

public fun quilt_id(self: &ImageVariant): String {
    self.quilt_id
}
