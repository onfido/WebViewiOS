function sendSuccessMessage() {
    /// The successHandler part needs to be configured on the native side, otherwise it will be undefined.
    window.webkit.messageHandlers.successHandler.postMessage("Success");
}

function sendErrorMessage() {
    /// The errorHandler part needs to be configured on the native side, otherwise it will be undefined.
    window.webkit.messageHandlers.errorHandler.postMessage("Error!");
}

onfido.setOptions({ onComplete: () => { sendSuccessMessage(); }, onError: () => { sendErrorMessage(); } })
