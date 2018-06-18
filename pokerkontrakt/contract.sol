pragma solidity ^0.4.24;

contract PokerGame{
    
uint reqDeposit = 10;
address[10] table;
mapping(address => bool) shuffled;
address dealer = 0;
uint encrStartedTime;

uint[52] encrDeck;

event WaitingForShuffles(
    string shuffleString
);

function SignUp(uint16 spot) public payable returns (uint16){
    require(msg.value == reqDeposit, "You need to pay a deposit to be able to play");
    require(spot < 10, "Need to provide an open spot between 1 and 9");
    if(table[spot] == 0){
        table[spot] = msg.sender;
        if(dealer == 0){
            dealer = msg.sender;
        }
        return spot;
    }
    else{
        return 0;
    }
}


function FirstEncr(uint[52] firstEncr) public {
    require(msg.sender == dealer);
    encrDeck = firstEncr;
    encrStartedTime = now;
    
    emit WaitingForShuffles("Still waiting for all players to encrypt and shuffle deck");
}

function ForceStart(){
    if(now > encrStartedTime + 1 minutes){
        KickUnshuffled();
        StartGame();
    }
}

function KickUnshuffled() private{
    for(uint16 i=0; i<10; i++){
        if(table[i] == 0){
            continue;
        }
        if(!shuffled[table[i]]){
            table[i] = 0; //should refund deposit and all that
        }
    }
}

function CheckShuffled() public view returns (bool) {
    return shuffled[msg.sender];
}

function EncryptAndShuffle(uint[52] newDeck) public {
    require(IsInGame(msg.sender));
    encrDeck = newDeck;
    
    StartIfAllEncrypted();
}

function StartIfAllEncrypted() private {
    for(uint16 i=0; i<10; i++){
        if(table[i]== 0){
            continue;
        }
        if(shuffled[table[i]] == false) {
            emit WaitingForShuffles("At least one player has not shuffled");
            return;
        }
    }
    StartGame();
}

function StartGame() private {
    
}

function IsInGame(address addr) private view returns (bool){
    for(uint16 i; i<10; i++){
        if(table[i] == addr){
            return true;
        }
    }
    return false;
}



function CheckTable() public view returns (address[10]){
    return table;
}

function CheckDealer() public view returns (address) {
    return dealer;
}
}