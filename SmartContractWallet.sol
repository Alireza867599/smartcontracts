// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract consumer{
    function getbalance() public view returns(uint){
        return address(this).balance;
    }

    function deposit() public payable {}
}

contract SmartContractWallet{

    address  payable public owner;
    mapping (address =>uint) public  allowance;
    mapping (address =>bool) public isallowedToSend;

    mapping (address =>bool) public  guardians;
    mapping (address =>mapping (address =>bool)) nextownerGuardianVotebool;
    address payable nextowner;
    uint guardiansresetcount;
    uint public constant confirmationsfromguradiansforreset = 3;



    constructor(){
        owner = payable (msg.sender);

    }
    function setguardian(address _guardian, bool isguardian) public {
        require(msg.sender == owner, "you are not owner , aborting");
        require(nextownerGuardianVotebool[nextowner][msg.sender]= true, "you  already voted , aborting");

        guardians[_guardian] = isguardian;

    }

    function proposednewowner(address payable _newowner)public {
        require(guardians[msg.sender], "you are not guardians of this wallet, go away");
        if(_newowner !=nextowner){
            nextowner = _newowner;
            guardiansresetcount = 0;
        }
        guardiansresetcount++;
        if(confirmationsfromguradiansforreset == guardiansresetcount){
            owner = nextowner;
            nextowner =payable(address(0));
        }
    }   

    function setallowence(address _for , uint amount) public {
        require(msg.sender == owner, "you are not owner , aborting");
        allowance[_for] = amount;
        if(amount > 0){
            isallowedToSend[_for] = true;
        }
        else{
            isallowedToSend[_for] = false;

        }
    }

    function transfer(address payable  _to , uint _amount, bytes memory _payload) public returns(bytes memory){
        // require(msg.sender ==owner ,"you are not owner ");
        if(msg.sender !=owner){
            require(isallowedToSend[msg.sender], "you are not allowed to send anything from smart contract, aborting");
            require(allowance[msg.sender] >=_amount, "you are trying to send more money you have , aborting");
            allowance[msg.sender] -= _amount;
        }
        (bool success, bytes memory returnData) =_to.call{value :_amount}(_payload);
        require(success,"aborting , call was not successful");
        return returnData;

    }

    receive() external payable { }
}