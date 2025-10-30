// SPDX-License-Identifier: CC-BY-NC-4.0
// © 2025 Studio Mirai. Non-commercial use only.
module tamashi::admin;

public struct ADMIN() has drop;

public struct AdminCap has key, store {
    id: UID,
}

fun init(_otw: ADMIN, ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::public_transfer(admin_cap, @admin);
}
