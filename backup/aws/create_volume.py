import boto3

from settings import kms_key_id, volume_size, volume_type

ec2 = boto3.resource('ec2')
volume_name = "montagu_barman_volume"


def volume_matches(v):
    if v.tags:
        return any(t for t in v.tags
               if t['Key'] == 'Name' and t['Value'] == volume_name)
    else:
        return False


def get_or_create_volume():
    volumes = [v for v in ec2.volumes.all() if volume_matches(v)]
    count = len(volumes)
    if count > 1:
        raise Exception("More than one barman volume exists in AWS")
    elif count == 1:
        volume = volumes[0]
        print("Found existing volume with id {}. Barman will reuse existing "
              "data".format(volume.id))
        if any(volume.attachments):
            raise Exception("Volume is still attached to old instance. Wait "
                            "and try again")
        return volume
    else:
        print("Volume does not exist, creating...")
        return create_volume()


def create_volume():
    return ec2.create_volume(
        AvailabilityZone="eu-west-2a",
        Encrypted=True,
        KmsKeyId=kms_key_id,
        Size=volume_size,
        VolumeType=volume_type,
        TagSpecifications=[
            {
                'ResourceType': 'volume',
                'Tags': [
                    {
                        'Key': "Name",
                        'Value': "montagu_barman_volume"
                    }
                ]
            }
        ]
    )
