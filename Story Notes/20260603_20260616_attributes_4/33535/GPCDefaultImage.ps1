param (
    [Parameter(Mandatory = $true)]
    [string] $productId
)

# using the passed in id, query the GPC for the default image for that product
# and return the image url
[string] $GPCDefaultImageEndpoint = "https://gpc.veodesignstudio.com/products/$productId" 

try {
    $response = Invoke-WebRequest -Uri $GPCDefaultImageEndpoint -UseBasicParsing
    $responseData = $response.Content | ConvertFrom-Json
    return $responseData.defaultImageUrl
} catch {
    return "Failed to retrieve default image for product ID: $productId. Error: $_"
}