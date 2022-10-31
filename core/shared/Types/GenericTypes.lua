export type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

export type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

return {}