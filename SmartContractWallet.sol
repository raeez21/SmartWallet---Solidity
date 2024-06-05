//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// A helper contract to receive money from the main wallet
contract Consumer{
    function getBalance() public view returns(uint){
        return address(this).balance;
        //returns the balance of this SC
    }
    function deposit() public payable{
            //This just receivees from the main wallet and stores that money in this SC
            //TODO write the corresponding logic here---> maybe move the SC money to a parent account
    }
}
contract SmartContractWallet {
    address payable public owner;       //Current owner of the Wallet
    mapping (address=>uint) public allowance;   //Mapping of address to allowance amount. Shows how much each address can spend
    mapping (address=>bool) public isAllowedToSend; //Whether this address is allowed to Send or Not
    mapping (address=>bool) public guardians;   //Mapping of Guardians
    mapping (address => mapping(address=>bool)) public nextOwnerGuardianVoted; // [nextOwner]--->[Guardian]--->[true] means for this candidate of next owner, this guardian already voted
    address payable nextOwner;      //Candidate Next owner
    uint guardiansResetCount;       //Count
    uint public constant confirmationsFromGuardiansForReset = 3;    //Min vote needed for setting a new owner

    constructor(){
        //Setting the owner as the address which deploys this SC
        owner = payable(msg.sender);
        isAllowedToSend[msg.sender] = true;
    }
    function setGuardian(address _guardian, bool _isGuardian) public{
        // Owner can set a guardian. 
        require(msg.sender == owner,"You are not the owner, aborting");
        guardians[_guardian] = _isGuardian;

    }
    function proposeNewOwner(address payable _newOwner) public{
        //Only the guardians can propose a new owner
        require(guardians[msg.sender],"You are not guardian of this wallet, aborting");
        
        //Checks if a guardian has already voted for this candidate
        require(nextOwnerGuardianVoted[_newOwner][msg.sender] == false, "You already voted, aborting");
        if(_newOwner != nextOwner){
            nextOwner = _newOwner;
            guardiansResetCount = 0;
        }
        guardiansResetCount++; //Cast the Vote by this guardian for a candidate
        nextOwnerGuardianVoted[_newOwner][msg.sender] = true;
        if(guardiansResetCount >= confirmationsFromGuardiansForReset){
            //Setting the candidate as new owner if atleas 3 guardians selected
            owner = nextOwner;
            nextOwner = payable(address(0));
        }        

    }
    function setAllowance(address _for, uint _amt)public{
        //Only owner can set allowances
        require(msg.sender == owner,"You are not the owner, aborting");
        allowance[_for] = _amt;
        if(_amt > 0){
            isAllowedToSend[_for] = true;
        }else{
            isAllowedToSend[_for] = false;
        }
    }
    function transfer(address payable _to, uint _amt, bytes memory _payload) public returns(bytes memory){
        // require(msg.sender == owner, "You are not the owner, aborting!!");
        
        // Either the owner or a authorised address can send money through this SC
        if(msg.sender != owner){
            require(isAllowedToSend[msg.sender], "You are not allowed to send anything from this contract, Aborting");
            require(allowance[msg.sender] >= _amt, "You are trying to send more than you are allowed to, Aborting");
            allowance[msg.sender] -= _amt;    //Allowance reduced
        }
        (bool success, bytes memory returnData) = _to.call{value:_amt}(_payload);
        require(success,"Aborting, call was not successful");
        return returnData;
    }
    receive() external payable {

     }
}

