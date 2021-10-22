pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

contract CloverNFT {
    
    address public owner;
    uint256 feeCreateToken = 1;
    uint256 lastTokenId;
    
    
    struct CloverToken {
      string url;
      string hash;
      uint256 price; //IN WEI
      bool allow_sell;
    }
    CloverToken[]  tokens;

    

    constructor() payable {
        owner = msg.sender;
    }
    
    
    function testi(uint _i) public returns(uint i){
        return _i;
    }
    

    
    function getCreateFee() public view returns(uint256 price){
        return feeCreateToken;
    }

    function setCreatePrice(uint256 _new_fee) public {
       require(msg.sender == owner);
      feeCreateToken = _new_fee;
    }
    
    function test_func() public returns(uint){
      return 333;
    }

   function removeToken(address owner, uint256 _tokenId) private {
       tokenExists[_tokenId] = false;
       countOwnerTokens[owner]--;

   }

    function tests(string memory _s) public returns(string memory s) {
        return _s;
    }

    function fallback() public payable {
    //    emit GotPaid(msg.value);
    }
/*
    function testCreate(string memory _url, uint   _price, bool  _allow_sell) public returns(uint256 tokenId) {
        uint256 tokenId = 0;
        CloverToken memory newToken = CloverToken(
            _url,
            _price,
            _allow_sell
        );
        
        //if(msg.value >= price_create_token){
            //payable(msg.sender).transfer(msg.value - price_create_token);   

            tokens.push(newToken);
            tokenId = tokens.length;
            lastTokenId = tokenId;

            tokenOwners[tokenId] = msg.sender;
            tokenExists[tokenId] = true;
            countOwnerTokens[msg.sender]++;

        //}                
        return tokenId;
    }
*/
   //create new token
   function createToken(string memory _url, string memory _hash, uint256   _price, bool  _allow_sell) public payable returns ( uint256  newTokenId ){
        uint256 tokenId = 0;
        CloverToken memory newToken = CloverToken(
            _url,
            _hash,
            _price,
            _allow_sell
        );
        
        if(msg.value >= feeCreateToken){
            if(msg.value > feeCreateToken){
              payable(msg.sender).transfer(msg.value - feeCreateToken);   
            }

            tokens.push(newToken);
            tokenId = tokens.length;
            lastTokenId = tokenId;

            tokenOwners[tokenId] = msg.sender;
            tokenExists[tokenId] = true;
            countOwnerTokens[msg.sender]++;

        }                
        return tokenId;
   }



   string constant private tokenName = "CloverNet NFT";
   string constant private tokenSymbol = "CFT";
   //uint256 constant private totalTokens = 1000000;
   //mapping(address => uint) private balances;
   mapping(uint256 => address) public tokenOwners;
   mapping(uint256 => bool) private tokenExists;
   mapping(address => mapping (address => uint256)) private allowed;
   mapping(address => uint) private countOwnerTokens;

   mapping(uint256 => string) tokenLinks;


    function getTokenPrice(uint256 _tokenId) public  returns(uint256 price){
      require(tokenExists[_tokenId]);
      CloverToken memory token; 
      token = getToken(_tokenId);
      return token.price;
  
    }

    function getTokenPrice2(uint256 _tokenId) public returns(uint price){
      return lastTokenId;
    }



    function getTokenExist(uint256 _tokenId) public view returns(bool exist){
      return tokenExists[_tokenId];
    }

    function getTokenOwner(uint256 _tokenId) public view returns(address owner){
      return tokenOwners[_tokenId];
    }


    function buyToken2(uint256 _tokenId) public payable {
          require(tokenExists[_tokenId]);
            countOwnerTokens[tokenOwners[_tokenId]]--;
            countOwnerTokens[msg.sender]++;

            tokenOwners[_tokenId] = msg.sender;
    
    }

   function transfer(address _to, uint256 _tokenId) private {
       address currentOwner = msg.sender;
       address newOwner = _to;
       require(tokenExists[_tokenId]);
       require(currentOwner == ownerOf(_tokenId));
       require(currentOwner != newOwner);
       require(newOwner != address(0));
       //removeToken(_tokenId);
       tokenOwners[_tokenId] = newOwner;
       countOwnerTokens[currentOwner]--;
       countOwnerTokens[newOwner]++;
       //Transfer(currentOwner, newOwner, _tokenId);
   }

   function deleteToken(uint256 _tokenId) public {
       require(tokenExists[_tokenId]);
       require(msg.sender == ownerOf(_tokenId));
       countOwnerTokens[msg.sender]--;
       tokenExists[_tokenId] = false;

   }

    function buyToken(uint256 _tokenId) public payable {
      if(tokenExists[_tokenId] && tokenOwners[_tokenId] != msg.sender  )
      {
        CloverToken memory token; 
        token = getToken(_tokenId);
        if(msg.value >= token.price){
            countOwnerTokens[tokenOwners[_tokenId]]--;
            countOwnerTokens[msg.sender]++;

            tokenOwners[_tokenId] = msg.sender;

            //money back
            if(msg.value > token.price){
              payable(msg.sender).transfer(msg.value - token.price);   
            }
        }else{
          //money back
          payable(msg.sender).transfer(msg.value);   
        }
      }else{
        //money back
        payable(msg.sender).transfer(msg.value);   
      }

    }



   function getTokensForSale(uint256 _start, uint _limit)  external view returns(uint256[] memory tokensList) {
        uint256 totalTokens = tokens.length;
        if((_start >= totalTokens-1) && (_start <= totalTokens)){
            uint256[] memory result = new uint256[](_limit);
            uint256 tokenId;
            uint256 resultIndex = 0;

            for (tokenId = _start + 1; tokenId <= _start + _limit + 1; tokenId++) {
                if ((tokenExists[tokenId] == true) ) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }
            return result;
        }else{
            return new uint256[](0);
        }
   }


    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint tokenCount = countOwnerTokens[_owner];

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = tokens.length;
            uint256 resultIndex = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if ((tokenExists[tokenId] == true) && (tokenOwners[tokenId] == _owner)) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
    

   function name() public returns (string memory){
       return tokenName;
   }
   function symbol() public returns (string memory) {
       return tokenSymbol;
   }
   function ownerOf(uint256 _tokenId)  public returns (address){
       require(tokenExists[_tokenId]);
       return tokenOwners[_tokenId];
   }
   function approve(address _to, uint256 _tokenId) public {
       require(msg.sender == ownerOf(_tokenId));
       require(msg.sender != _to);
       allowed[msg.sender][_to] = _tokenId;
       //Approval(msg.sender, _to, _tokenId);
   }
   function takeOwnership(uint256 _tokenId) private{
       require(tokenExists[_tokenId]);
       address oldOwner = ownerOf(_tokenId);
       address newOwner = msg.sender;
       require(newOwner != oldOwner);
       require(allowed[oldOwner][newOwner] == _tokenId);
       tokenOwners[_tokenId] = newOwner;
       //Transfer(oldOwner, newOwner, _tokenId);
   }

   function getCountOwnerTokens(address _owner) public view returns (uint countTokens){
      return countOwnerTokens[_owner];
   }

   function updateToken(uint256 _tokenId, uint256   _price, bool  _allow_sell) public{
      require(tokenExists[_tokenId]);
      require(tokenOwners[_tokenId] == msg.sender);
      tokens[_tokenId-1].price = _price;
      tokens[_tokenId-1].allow_sell = _allow_sell;
   }



   function getToken(uint256 _tokenId) public returns (CloverToken memory token){
       require(tokenExists[_tokenId]);
       return tokens[_tokenId-1];
   }
}