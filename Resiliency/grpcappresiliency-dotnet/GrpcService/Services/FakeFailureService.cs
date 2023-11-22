using Grpc.Core;
using GrpcService;
using System;

namespace GrpcService.Services
{
    public class FakeFailureService : FakeFailure.FakeFailureBase
    {
        private readonly ILogger<FakeFailureService> _logger;
        public FakeFailureService(ILogger<FakeFailureService> logger)
        {
            _logger = logger;
        }

        public override Task<FailureReply> SayFail(FailureRequest request, ServerCallContext context)
        {
            Console.WriteLine("Entering gRPC server failure method.");
            throw new RpcException(new Status(StatusCode.Unavailable, "Failure"), "fake info");
        }
    }
}