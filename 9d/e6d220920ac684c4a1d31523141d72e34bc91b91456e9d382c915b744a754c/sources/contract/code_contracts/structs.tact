import "@stdlib/deploy";

// ReferralSystem structs 
struct UserData {
    referrerKey: Int;
    address: Address;
    referralsCount: Int;
    earningsFromReferrals: Int;
    lastActivity: Int;
}

struct Users {
    userData: map<Int, UserData>;
    addresses: map<Address, Int>;
    lastKey: Int;
    // Плотный (без дыр) индекс живых пользователей: позиция -> ключ.
    // Поддерживается через swap-remove при удалении, чтобы уборка обходила
    // только живых, не тратя газ на удалённые слоты.
    userIndex: map<Int, Int>;
    userCount: Int;
}

// Состояние амортизированной уборки неактивных пользователей. Уборка идёт
// «по ходу жизни» контракта: на каждой покупке кольцевой курсор проверяет
// несколько слотов плотного индекса. Персистентного состояния нужен только
// сам курсор — он переживает между транзакциями и продолжает обход с того места,
// где остановился.
struct PruneState {
    cursor: Int;
}

// LotterySystem structs
struct LotteryBank {
    balance: Int;
}

struct PastLotteryInformation {
    lastLotteryTime: Int;
    lastWinnerKey: Int;
    lastWinnerAddress: Address;
    lastWinAmount: Int;
    totalWinners: Int;
    totalWinsAmount: Int;
}

struct CurrentLotteryRound {
    endTime: Int;
    ticketMap: map<Int, Int>;
    participantList: map<Int, Int>;
    totalTickets: Int;
    participantsCount: Int;
}

struct DrawState {
    isDrawing: Bool;
    cursor: Int;
    accumulated: Int;
    randomTarget: Int;
    winnerKey: Int;
    winnerFound: Bool;
    snapshotParticipants: Int;
    prizeAmount: Int;
    ownerShareAmount: Int;
    // Время последнего прогресса чанка розыгрыша (heartbeat для watchdog).
    lastProgressTime: Int;
}

// JettonRewards structs
struct JettonRewardsStats {
    lastMintTime: Int;
    totalMinted: Int;
}

// GasManager structs
struct GasDeductionResult {
    initialAmount: Int;     
    gasAmount: Int;  
    remainingAmount: Int;   
    isEnough: Bool;         
}

struct StorageStats {
    lastUpdateTime: Int;             
    transactionCount: Int;          
    totalTimeInterval: Int;         
    totalStorageDueCollected: Int;  
    reservedStorage: Int;           
    storageLimit: Int;              
    lastTonsReserve: Int;            
    storageTonsDeficit: Int;   
}

// PRMDJettonMaster structs
struct MultiMintReceiver {
    receiver: Address;
    amount: Int as coins;
    tonAmount: Int as coins;
    responseDestination: Address;
    forwardAmount: Int as coins;
    forwardPayload: Cell?;
}

struct JettonWalletData {
    balance: Int as coins;
    owner: Address;
    master: Address;
    walletCode: Cell;
}

struct JettonMasterData {
    totalSupply: Int as coins;
    mintable: Bool;
    owner: Address;
    content: Cell;
    walletCode: Cell;
}

//Getter structs
//
// IMPORTANT (scalability): the getter structs below intentionally contain ONLY
// scalar fields — never the on-chain maps (userData/addresses/userIndex,
// ticketMap/participantList). A get method serializes everything it returns
// into a single BoC, so embedding those maps would make the response grow
// linearly with state size (millions of users -> tens of MB, eventually hitting
// get-method gas / response-size limits). `getPyramidaState` therefore returns a
// constant-size global snapshot, and a single user's record is read on demand
// via `getUserByAddress(address)`.

// Constant-size summary of the current lottery round (no maps).
struct CurrentRoundSummary {
    endTime: Int;
    totalTickets: Int;
    participantsCount: Int;
}

// Constant-size summary of the user registry (no maps).
struct UsersSummary {
    lastKey: Int;
    userCount: Int;
}

struct PyramidaState {
    lotteryBank: LotteryBank;
    pastLotteryInfo: PastLotteryInformation;
    currentRound: CurrentRoundSummary;
    drawState: DrawState;
    pruneState: PruneState;
    users: UsersSummary;
    jettonRewardsStats: JettonRewardsStats;
    owner: Address;
    jettonMasterAddress: Address;
}

// Single user's record, read on demand by address. `registered` is false when
// the address has never bought a ticket (all other fields are then zero/default).
struct UserView {
    registered: Bool;
    key: Int;
    referrerKey: Int;
    address: Address;
    referralsCount: Int;
    earningsFromReferrals: Int;
    lastActivity: Int;
}