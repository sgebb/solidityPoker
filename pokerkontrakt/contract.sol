pragma solidity ^0.5.6;

contract PokerGame{

//table    
address[2] table;
mapping(address => uint) indexOf;

//shuffling
mapping(address => bool) shuffled;
uint[3] encrDeck;
address shuffleResponsible;

//game
address dealer = address(0);
bool openTable = true;


//event
event TimeToShuffle(address nextShuffler);
event PlayerJoined(address player);
event PlayerLeft(address player);
event NeedDecryption(address player, uint16 index);

function Join(uint8 spot) public payable{
    //take deposit
    require(spot < 2, "Need to provide an open spot between 0 and 1");
    require(openTable, "Can't join in the middle of a game");
    if(table[spot] == address(0)){
        table[spot] = msg.sender;
        indexOf[msg.sender] = spot;

        if(dealer == address(0)){
            dealer = msg.sender;
            shuffleResponsible = msg.sender;
        }
        emit PlayerJoined(msg.sender);
    }
}

function Leave() public {
    require(indexOf[msg.sender] != 0, "You're not in the game");
    if(msg.sender == dealer){
        dealer = address(0);
    }
    delete table[indexOf[msg.sender]];
    indexOf[msg.sender] = 0;
    emit PlayerLeft(msg.sender);
    //refund deposit
}


function Shuffle(uint[3] memory encryptedCards) public {
    require(msg.sender == shuffleResponsible, "Not your turn to shuffle");
    encrDeck = encryptedCards;
    shuffled[msg.sender] = true;
    shuffleResponsible = table[indexOf[msg.sender]+1]; //cycle through (but without bugs eventually)
    if(AllEncrypted()){
        openTable = false;
        StartGame();
    }
    else{
        emit TimeToShuffle(shuffleResponsible); 
    }
}


function AllEncrypted() private view returns(bool){
    for(uint8 i=0; i<2; i++){
        if(table[i]== address(0)){
            continue;
        }
        if(shuffled[table[i]] == false) {
            return false;
        }
        return true;
    }
}


function StartGame() private {
    
}

function EndGame() private {
    openTable = true;
}


function CheckTable() public view returns (address[2] memory) {
    return table;
}

function Deck() public view returns (uint[3] memory){
    return encrDeck;
}
}
