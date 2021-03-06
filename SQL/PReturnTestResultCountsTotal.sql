
/****** Object:  StoredProcedure [dbo].[PReturnTestResultCountsTotal]    Script Date: 1/3/2015 10:36:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Brian Kresge, MBA
-- Create date: 12/22/14
-- Description:	Returns counts of various categories of tests across 14 days
-- =============================================
CREATE PROCEDURE [dbo].[PReturnTestResultCountsTotal]
	@projectid int
AS
BEGIN

SELECT		a.StatusID,b.[Status], count(a.id) as ItemCount
FROM		TTestResult a
INNER JOIN	TTestStatus b on a.StatusID = b.id
INNER JOIN  TTestCase c on a.TestCaseID = c.id
WHERE		c.ProjectID = @projectid
GROUP BY	a.StatusID,b.[Status]

END

GO

