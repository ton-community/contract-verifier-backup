// ============================================================
//  common.tolk — Shared types, enums, opcodes, and constants
//  TON Monthly Rent Escrow System — Tolk 1.3.0
// ============================================================

// ─── Op-codes ────────────────────────────────────────────────────────────────
const OP_JETTON_TRANSFER              = 0xf8a7ea5;
const OP_JETTON_TRANSFER_NOTIFICATION = 0x7362d09c;
const OP_JETTON_EXCESSES              = 0xd53276db;

const OP_DEPLOY_LEASE                 = 0x11111001;
const OP_FACTORY_WITHDRAW             = 0x11111002;

const OP_TENANT_CONFIRM_CHECKIN       = 0x22220001;
const OP_TENANT_CONFIRM_CHECKOUT      = 0x22220002;
const OP_TENANT_OPEN_DISPUTE          = 0x22220003;
const OP_TENANT_REQUEST_TERMINATION   = 0x22220004;

const OP_LANDLORD_MARK_READY          = 0x33330001;
const OP_LANDLORD_INSPECT_PROPERTY    = 0x33330002;
const OP_LANDLORD_OPEN_DISPUTE        = 0x33330003;

const OP_ADMIN_SET_ACTIVE             = 0x44440001;
const OP_ADMIN_CLAIM_MONTH            = 0x44440002;
const OP_ADMIN_SETTLE_DISPUTE         = 0x44440003;
const OP_ADMIN_FORCE_CHECKOUT         = 0x44440004;
const OP_ADMIN_FORCE_COMPLETE         = 0x44440005;
const OP_ADMIN_TERMINATE              = 0x44440006;
const OP_ADMIN_SETTLE_CHECKOUT        = 0x44440007;

const OP_LEASE_INIT_DEPOSIT           = 0x55550001;

const OP_NOTIFY_LEASE_DEPLOYED        = 0x66660001;
const OP_NOTIFY_MONTH_RELEASED        = 0x66660004;
const OP_NOTIFY_DISPUTE_RESOLVED      = 0x66660006;
const OP_NOTIFY_CHECKOUT_COMPLETE     = 0x66660007;
const OP_NOTIFY_TERMINATED            = 0x66660008;

// ─── Global state enum ───────────────────────────────────────────────────────
const GS_CREATED    = 0;
const GS_CHECKIN    = 1;
const GS_ACTIVE     = 2;
const GS_CHECKOUT   = 3;
const GS_COMPLETED  = 4;
const GS_DISPUTE    = 5;
const GS_TERMINATED = 6;

// ─── Check-in sub-states ─────────────────────────────────────────────────────
const CI_PENDING   = 0;
const CI_READY     = 1;
const CI_CONFIRMED = 2;

// ─── Check-out sub-states ────────────────────────────────────────────────────
const CO_PENDING    = 0;
const CO_TENANT_OUT = 1;
const CO_INSPECTION = 2;
const CO_SETTLED    = 3;

// ─── Monthly state enum ──────────────────────────────────────────────────────
const MS_PENDING  = 0;
const MS_PAID     = 1;
const MS_RELEASED = 2;
const MS_DISPUTE  = 3;

// ─── Replay guard ────────────────────────────────────────────────────────────
// Checks query_id against processed dict; throws ERR_REPLAY if duplicate.
// Returns updated dict with query_id recorded.
fun checkAndRecordQueryId(processedIds: cell, queryId: int, nowTs: int): cell {
    var dict = processedIds;
    var (_, found) = dict.uDictGet(64, queryId);
    throw_if(ERR_REPLAY, found);
    dict.uDictSetBuilder(64, queryId, beginCell().storeUint(nowTs, 32));
    return dict;
}
