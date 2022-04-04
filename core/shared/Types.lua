export type AnimationData = { 
    Name: string,
    TrackId: number,
    MarkerSignals: {[string]: () -> ()}
}
return nil