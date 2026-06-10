unit GenAI.Responses.Internal;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Async.Promise,
  GenAI.Responses.InputItemList,
  GenAI.Responses.OutputParams;

type
  TResponseEvent = reference to procedure(var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean);

  TAsynResponse = TAsynCallBack<TResponse>;
  TPromiseResponse = TPromiseCallBack<TResponse>;

  TAsynResponseCompaction = TAsynCallBack<TResponseCompaction>;
  TPromiseResponseCompaction = TPromiseCallBack<TResponseCompaction>;

  TAsynResponseStream = TAsynStreamCallBack<TResponseStream>;
  TPromiseResponseStream = TPromiseStreamCallBack<TResponseStream>;

  TAsynResponseDelete = TAsynCallBack<TResponseDelete>;
  TPromiseResponseDelete = TPromiseCallBack<TResponseDelete>;

  TAsynResponses = TAsynCallBack<TResponses>;
  TPromiseResponses = TPromiseCallBack<TResponses>;

  TAsynResponseStreamFunc = TFunc<TPromiseResponseStream>;

implementation

end.
