// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Ebay{
    struct Auction{
        uint id;
        address payable seller;
        string name;
        string description;
        uint minValue;
        uint bestOfferId;
        uint[] offerIds;
    }
    struct Bid{
        uint id;
        uint auctionId;
        address payable buyer;
        uint price;
    }
    mapping (uint => Auction) public auctions;
    mapping (uint => Bid) private Bids;
    mapping (address=> uint[]) private auctionList;
    mapping (address => uint[]) private offerList;

    uint private newAuctionId = 1;
    uint private newOfferId = 1;

    function createAuction(string calldata _name, string calldata _description, uint _min) external {
        require(_min > 0, "value must be greater than 0");
        uint[] memory offerIds = new uint[](0);

        auctions[newAuctionId] = Auction(newAuctionId, payable(msg.sender), _name, _description, _min, 0, offerIds);
        auctionList[msg.sender].push(newAuctionId);
        newAuctionId++;
    }

    function createOffer(uint _auctionId) external payable auctionExists(_auctionId){
        Auction storage auction = auctions[_auctionId];
        Bid storage bestOffer = Bids[auction.bestOfferId];

        require(msg.value>=auction.minValue && msg.value>bestOffer.price, "value is not enough for transaction");
        auction.bestOfferId = newOfferId;
        auction.offerIds.push(newOfferId);

        Bids[newOfferId] = Bid(newOfferId,_auctionId,payable(msg.sender),msg.value);
        offerList[msg.sender].push(newOfferId);
        newOfferId++;
    }

    function transaction(uint _auctionId)external auctionExists(_auctionId){
        Auction storage auction = auctions[_auctionId];
        Bid storage bestOffer = Bids[auction.bestOfferId];

        for(uint i=0; i<auction.offerIds.length; i++){
            uint offerId = auction.offerIds[i];

            if(offerId!=auction.bestOfferId){
                Bid storage bid = Bids[offerId];
                bid.buyer.transfer(bid.price);
            }
        }
        auction.seller.transfer(bestOffer.price);
    }

    function getAuctions() external view returns(Auction[] memory){
        Auction[] memory _auctions = new Auction[](newAuctionId-1);

        for(uint i=1;i<newAuctionId;i++){
            _auctions[i-1]=auctions[i];
        }
        return _auctions;
    }
    
    function getUserAuctions(address _user) external view returns(Auction[] memory){
        uint[] storage userAuctionIds = auctionList[_user];
        Auction[] memory _auctions = new Auction[](userAuctionIds.length);
        for(uint i=0;i<userAuctionIds.length;i++){
            uint auctionId = userAuctionIds[i];
            _auctions[i] = auctions[auctionId];
        }
        return _auctions;
    }
    function getUserOffers(address _user) external view returns(Bid[] memory){
        uint[] storage userOfferIds=offerList[_user];
        Bid[] memory _bids = new Bid[](userOfferIds.length);
        
        for(uint i=0;i<userOfferIds.length;i++){
            uint offerId = userOfferIds[i];
            _bids[i]=Bids[offerId];
        }
        return _bids;
    }
    modifier auctionExists(uint _auctionId){
        require(_auctionId>0 && _auctionId<newAuctionId,"Auction does not exist");
        _;
    }
}
