Gen Stage in RMC

File and UDP transmit packets to Data In

Data In sends packets to Parse Packet

Parse Packet sends to Update Race

Race State dispatches events using GenStage.PartitionDispatcher
handle_events will merge in parsed packets and produce partitioned events if the session time has advanced

Channels and Serial subscribe to their partition from Race State