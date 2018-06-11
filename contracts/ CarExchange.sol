pragma solidity ^0.4.18;


import "./XCHNGTOken.sol";

contract CarExchangeInterface {
    // register a car
    function register(address _owner, uint _vinNumber ) public returns (bool success);
    // buy a car by _vinNumber that is listed for sale 
    function buyCar(uint _vinNumber, uint _value) public returns (bool success);
    // list a car for sale by _vinNumber 
    function list(uint _vinNumber, uint _value) public returns (bool success); 
    // ownedCars display a list of cars belonging to an owner   
    function ownedCars( address _owner) external view returns (uint[] vinNumbers);  
    //car price
    function price(uint _vinNumber) external view returns(uint);

    event Registered(uint indexed _vinNumber, address indexed _owner);
    event Bought(uint indexed _vinNumber, address indexed _oldOwner, address indexed _newOwner, uint _value);
    event Listed(uint indexed _vinNumber, address indexed _carOwner, uint _value);
}

contract CarExchange is CarExchangeInterface,XCHNGToken{

    //struct
    struct vinNumber{
    
        uint[] vinNumbers;
    }
    
    //mappings
    mapping(address=>vinNumber)registerCar;
    mapping(uint=>address) carOwner;
    mapping(uint=>bool) vinExists;
    mapping(uint=>uint) carPrice;
    mapping(uint=>bool) carListed;
    

    //Register a car
    function register(address _owner,uint _vinNumber) public returns (bool success){
        if (vinExists[_vinNumber]==true) revert();
        registerCar[_owner].vinNumbers.push(_vinNumber);
        carOwner[_vinNumber] = _owner;
        vinExists[_vinNumber] = true;
        emit Registered(_vinNumber,_owner);
        return true;
        

    }

    // buy a car by _vinNumber that is listed for sale 
    function buyCar(uint _vinNumber, uint _value) public returns (bool success){
        if (carListed[_vinNumber]==false) revert();
        if (vinExists[_vinNumber]==false ) revert();
        if (carPrice[_vinNumber]!=_value) revert() ;
        if (carOwner[_vinNumber] == msg.sender) revert();
        address oldOwner = carOwner[_vinNumber];
        transfer(oldOwner,_value);
        for(uint index = 0;index<registerCar[oldOwner].vinNumbers.length;index++){
            if(registerCar[oldOwner].vinNumbers[index]==_vinNumber){
                    delete registerCar[oldOwner].vinNumbers[index];
            }
        }
        registerCar[msg.sender].vinNumbers.push(_vinNumber);
        carOwner[_vinNumber] = msg.sender;
        carListed[_vinNumber]=false;
        emit Bought(_vinNumber,oldOwner,msg.sender,_value);
        return true;
        
    }


    // list a car for sale by _vinNumber 
    function list(uint _vinNumber, uint _value) public returns (bool success){
        if (vinExists[_vinNumber]==false) revert();
        if(carOwner[_vinNumber]!=msg.sender) revert();
        if(carListed[_vinNumber]==true) revert();
        carPrice[_vinNumber]=_value;
        carListed[_vinNumber]=true;
        emit Listed(_vinNumber,msg.sender,_value);
        return true;
    }


    // ownedCars display a list of cars belonging to an owner   
    function ownedCars( address _owner) external view returns (uint[] _vinNumbers){
        return registerCar[_owner].vinNumbers;
    }
    
    
    //car price
    function price(uint _vinNumber) external view returns(uint){
        if (carListed[_vinNumber]==false) revert();
        return carPrice[_vinNumber];
        
    }
    







}
