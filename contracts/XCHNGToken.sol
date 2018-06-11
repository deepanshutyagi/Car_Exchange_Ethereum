pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract XCHNGToken is StandardToken,Ownable, SafeMath {

    // crowdsale parameters
    string  public constant name = "XCHNGCoin";
    string  public constant symbol = "XCHNG";
    uint256 public constant decimals = 18;
    string  public version = "1.0";
    address public constant ethFundDeposit=0x43E1Ab3771bCE66aaCb57a24e8adAf293146892A;                        
    bool public emergencyFlag;                                      
    uint256 public constant tokenSaleRate=800;    
    uint256 public constant tokenCreationCap =  100 * (10**6) * 10**decimals;      
    

    // events
    event CreateXCHNG(address indexed _to, uint256 _value);
    event Mint(address indexed _to,uint256 _value);    

   
    //It is a internal function it will be called by fallback function or buyToken functions.
    function createTokens() internal  {
      uint256 tokenExchangeRate=tokenRate();       
      uint256 tokens = safeMult(msg.value, tokenExchangeRate);
      totalSupply = safeAdd(totalSupply, tokens);            
      if(totalSupply>tokenCreationCap)revert();            
      balances[msg.sender] += tokens;                      
      forwardfunds();                                    
      emit CreateXCHNG(msg.sender, tokens);                      
    }

    
   // is a payable function it will be called by sender.
    
    function buyToken() payable external{
      createTokens();   // This will call the internal createToken function to get token
    }

       
    //It will return the token price at a particular time.
    
    function tokenRate() internal returns (uint256 _tokenPrice){
      // It is a presale it will return price for presale
            return tokenSaleRate;
    }

    //it will  assign token to a particular address by owner only
    
    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
      if (emergencyFlag) revert();
      totalSupply = safeAdd(totalSupply,_amount);
      if(totalSupply>tokenCreationCap)revert();
      balances[_to] +=_amount;                 
      emit  Mint(_to, _amount);                     
    }

    
    // Automate the ETH drain
    
    function forwardfunds() internal {
         if (!ethFundDeposit.send(this.balance)) revert(); 
        
        
    }
    
    // it will let Owner Stop the crowdsale and mint function to work.
    
    function emergencyToggle() external onlyOwner{
      emergencyFlag = !emergencyFlag;
    }

    // Fallback function let user send ether without calling the buy function.
    function() payable {
      createTokens();

    }

}