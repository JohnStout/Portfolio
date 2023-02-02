## The watson dataset
# Watson et al., recorded from PFC when rats were awake or sleeping in the bowl
# -------
# I am going to detect states of strong and weak theta in PFC, then examine how neurons 
# synchronize to oscillations

# dandiset ID
dandiset_id = '000041'

# libraries
import pynwb
import requests
from nwbwidgets import nwb2widget
from pynwb import NWBHDF5IO
import pandas
from dandi.dandiapi import DandiAPIClient
from pynwb import NWBHDF5IO
import os # import os

## some useful functions from Ben
def _search_assets(url, filepath):
    response = requests.request("GET", url, headers={"Accept": "application/json"}).json() 
    
    for asset in response["results"]:
        if filepath == asset["path"]:
            return asset["asset_id"]
    
    if response.get("next", None):
        return _search_assets(response["next"], filepath)
    
    raise ValueError(f'path {filepath} not found in dandiset {dandiset_id}.')

def get_asset_id(dandiset_id, filepath):
    url = f"https://api.dandiarchive.org/api/dandisets/{dandiset_id}/versions/draft/assets/"
    return _search_assets(url, filepath)

def get_s3_url(dandiset_id, filepath):

    """Get the s3 location for any NWB file on DANDI"""

    asset_id = get_asset_id(dandiset_id, filepath)
    url = f"https://api.dandiarchive.org/api/dandisets/{dandiset_id}/versions/draft/assets/{asset_id}/download/"
    
    s3_url = requests.request(url=url, method='head').url
    if '?' in s3_url:
        return s3_url[:s3_url.index('?')]
    return s3_url

## lets get all sessions for each rat
with DandiAPIClient() as client:
    
    # get dandiset using the ID code
    dandiset = client.get_dandiset(dandiset_id,'draft')
    
    # list splits the "zipped" generator file
    assets   = list(dandiset.get_assets())
    
    # list comprehension
    rats = {os.path.split(x.path)[0] for x in assets} # list comprehension, for loop, {} if unique

    # actually just work with sessions for now and call it a day
    sessions = [x.path for x in assets]
    #print(sessions)

    #asset = client.get_dandiset(dandiset_id, 'draft').get_asset_by_path(filepath)
    #s3_url = asset.get_content_url(follow_redirects=1, strip_query=True)

## -- get the data out
# select 1 session for now to get code working
tempAssetID = sessions[0]
asset_id = get_asset_id(dandiset_id, tempAssetID) # this is the URL for download
s3_path  = get_s3_url(dandiset_id, tempAssetID) # this is the path to streaming
print(asset_id)

# use the "Read Only S3" (ros3) driver to stream data directly from DANDI (or any other S3 location)
io = NWBHDF5IO(s3_path, mode='r', load_namespaces=True, driver='ros3')

# read nwb file according to the s3 bucket path
nwb = io.read()

#Get the fields within the NWB file
nwbFields = nwb.fields
print(nwbFields)

#from nwbwidgets import nwb2widget
#nwb2widget(nwb)

# read out the nwb file as it is a dict
nwbFile = nwb.electrodes['location'].data[:]
regions = list(nwbFile)

#print(nwb.processing['behavior'].data_interfaces['behavior'])
pd.Dataframe(np.array(nwb.processing['behavior'].data_interfaces['states'].columns))

df = pd.DataFrame(my_array, columns = ['Column_A','Column_B','Column_C'])

print(nwb.processing['behavior'])


# implement training day