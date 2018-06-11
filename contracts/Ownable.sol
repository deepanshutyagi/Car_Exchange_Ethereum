pragma solidity ^0.4.18;



contract Ownable {
  address public owner;

    
    //The Ownable constructor sets the original `owner` of the contract to the sender
  
    function Ownable() {
      owner = msg.sender;
    }
   
    // reverts if called by any account other than the owner.
    
    modifier onlyOwner() {
      require(msg.sender == owner);
    _;
    }
  
    // newOwner The address to transfer ownership to.
    
    function transferOwnership(address newOwner) onlyOwner {
      if (newOwner != address(0)) {
          owner = newOwner;
      }
    }

}