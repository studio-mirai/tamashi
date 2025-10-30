// SPDX-License-Identifier: CC-BY-NC-4.0
// © 2025 Studio Mirai. Non-commercial use only.

module tamashi::admin;

public struct ADMIN() has drop;

public struct AdminCap has key, store {
    id: UID,
}

const ADMIN_ADDRESSES: vector<address> = vector[
    @0xde0053243f3226649701a7fe2c3988be11941bf3ff3535f3c8c5bf32fc600220,
    @0x0760564b88d4d86026aec8c4b0ca695187174ac8138cb9e9a37c7837546039cb,
    @0x283a34f03619b04230f82469eb0584a7961970d86d9538ca8135877bc7e03063,
];

fun init(_otw: ADMIN, ctx: &mut TxContext) {
    ADMIN_ADDRESSES.do!(|addr| {
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        transfer::public_transfer(admin_cap, addr);
    })
}
