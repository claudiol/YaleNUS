echo "First ..."
curl -X GET "https://api.cloudflare.com/client/v4/zones/f64975b2ef75e68498f5cf1237a6c05b/dns_records?type=A&name=another.yalenus.edu.sg&content="172.19.17.227"&page=1&per_page=20&order=type&direction=desc&match=all"\
 -H "X-Auth-Email: it.service.subscriber@yale-nus.edu.sg"\
 -H "X-Auth-Key: 80ddf8458f30a996b7a6fdf3fa2c85d1ca03a"\
 -H "Content-Type: application/json"


echo "Specific DNS record search using content=..."
curl -X GET "https://api.cloudflare.com/client/v4/zones/f64975b2ef75e68498f5cf1237a6c05b/dns_records?type=A&content="172.19.17.227"&page=1&per_page=20&order=type&direction=desc&match=all"\
 -H "X-Auth-Email: it.service.subscriber@yale-nus.edu.sg"\
 -H "X-Auth-Key: 80ddf8458f30a996b7a6fdf3fa2c85d1ca03a"\
 -H "Content-Type: application/json"

echo "List all zones..."
curl -X GET "https://api.cloudflare.com/client/v4/zones"\
 -H "X-Auth-Email: it.service.subscriber@yale-nus.edu.sg"\
 -H "X-Auth-Key: 80ddf8458f30a996b7a6fdf3fa2c85d1ca03a"\
 -H "Content-Type: application/json"

